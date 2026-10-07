import argparse
import array
import os
import queue
import subprocess
import sys
import threading
from pathlib import Path

import openvino_genai as ov_genai
from huggingface_hub import snapshot_download
from openvino import Core


DEFAULT_MODEL = "OpenVINO/whisper-large-v3-turbo-int8-ov"
SAMPLE_RATE = 16000


def microphone_audio(source: str | None, chunk_seconds: float):
    """Capture raw audio without temporary files, including during inference."""
    command = [
        "pw-record", "--raw", "--format", "f32", "--rate", str(SAMPLE_RATE),
        "--channels", "1",
    ]
    if source is not None:
        command.extend(["--target", source])
    command.append("-")
    chunk_bytes = round(chunk_seconds * SAMPLE_RATE) * 4
    chunks = queue.Queue(maxsize=12)
    stopped = threading.Event()
    failures: list[str] = []

    with subprocess.Popen(command, stdout=subprocess.PIPE) as recorder:
        def capture() -> None:
            try:
                while not stopped.is_set():
                    data = recorder.stdout.read(chunk_bytes)
                    if not data:
                        break
                    try:
                        chunks.put_nowait(data)
                    except queue.Full:
                        failures.append(
                            "Transcription cannot keep up with microphone capture; "
                            "try a faster model or device, or increase --chunk-seconds."
                        )
                        break
                if not stopped.is_set() and not failures:
                    failures.append("Microphone capture stopped unexpectedly.")
            except (OSError, ValueError) as error:
                if not stopped.is_set():
                    failures.append(f"Microphone capture failed: {error}")
            finally:
                stopped.set()

        reader = threading.Thread(target=capture, daemon=True)
        reader.start()
        try:
            while True:
                if stopped.is_set() and chunks.empty():
                    raise SystemExit(failures[0] if failures else "Microphone stopped.")
                try:
                    data = chunks.get(timeout=0.2)
                except queue.Empty:
                    continue
                samples = array.array("f")
                # pw-record emits native-endian float32 samples in raw mode.
                samples.frombytes(data)
                yield samples.tolist()
        finally:
            stopped.set()
            if recorder.poll() is None:
                recorder.terminate()
            try:
                recorder.wait(timeout=5)
            except subprocess.TimeoutExpired:
                recorder.kill()
                recorder.wait()
            reader.join(timeout=5)


def positive_seconds(value: str) -> float:
    seconds = float(value)
    if not 0.1 <= seconds <= 30:
        raise argparse.ArgumentTypeError("chunk duration must be between 0.1 and 30 seconds")
    return seconds


def decode_audio(path: Path) -> list[float]:
    command = [
        "ffmpeg",
        "-v",
        "error",
        "-i",
        str(path),
        "-f",
        "f32le",
        "-ac",
        "1",
        "-ar",
        "16000",
        "pipe:1",
    ]
    try:
        decoded = subprocess.run(command, check=True, stdout=subprocess.PIPE).stdout
    except subprocess.CalledProcessError as error:
        raise SystemExit(f"Could not decode audio: {path}") from error

    samples = array.array("f")
    samples.frombytes(decoded)
    if sys.byteorder != "little":
        samples.byteswap()
    return samples.tolist()


def language_token(language: str) -> str | None:
    if language == "auto":
        return None
    if language.startswith("<|") and language.endswith("|>"):
        return language
    return f"<|{language}|>"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Continuously transcribe a microphone, or a file, with OpenVINO Whisper."
    )
    parser.add_argument(
        "input", type=Path, nargs="?",
        help="audio or video file (omit to capture the microphone)",
    )
    parser.add_argument(
        "--log-file", type=Path, required=True,
        help="append transcripts to this file as well as stdout",
    )
    parser.add_argument(
        "--source", help="PipeWire microphone node name or serial (default: default microphone)",
    )
    parser.add_argument(
        "--chunk-seconds", type=positive_seconds, default=5.0,
        help="microphone audio duration per transcription (default: 5 seconds)",
    )
    parser.add_argument(
        "--device",
        default=os.environ.get("OPENVINO_STT_DEVICE", "NPU"),
        help="OpenVINO device (default: NPU)",
    )
    parser.add_argument(
        "--model",
        default=os.environ.get("OPENVINO_STT_MODEL", DEFAULT_MODEL),
        help=f"Hugging Face model ID (default: {DEFAULT_MODEL})",
    )
    parser.add_argument(
        "--language",
        default="auto",
        help="language code such as en or zh (default: auto-detect)",
    )
    parser.add_argument(
        "--translate",
        action="store_true",
        help="translate speech to English instead of transcribing it",
    )
    parser.add_argument(
        "--timestamps",
        action="store_true",
        help="print segment timestamps after the transcript",
    )
    parser.add_argument(
        "--words",
        action="store_true",
        help="print word-level timestamps after the transcript",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.input is not None and not args.input.is_file():
        raise SystemExit(f"Input file does not exist: {args.input}")
    try:
        log = args.log_file.expanduser().open("a", encoding="utf-8", buffering=1)
    except OSError as error:
        raise SystemExit(f"Cannot open log file {args.log_file}: {error}") from error

    devices = Core().available_devices
    if args.device.startswith("NPU") and not any(
        device.startswith("NPU") for device in devices
    ):
        available = ", ".join(devices) or "none"
        raise SystemExit(
            f"OpenVINO cannot see the NPU (available devices: {available})"
        )

    cache_root = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache"))
    model_cache_name = args.model.replace("/", "--").lower()
    compile_cache = cache_root / "openvino" / "speech-to-text" / model_cache_name
    compile_cache.mkdir(parents=True, exist_ok=True)

    print(f"Downloading/checking {args.model}...", file=sys.stderr, flush=True)
    model_path = snapshot_download(repo_id=args.model)
    print(
        f"Compiling {args.model} on {args.device} "
        "(the first NPU run may take a few minutes)...",
        file=sys.stderr,
        flush=True,
    )
    pipeline_options: dict[str, object] = {
        "CACHE_DIR": str(compile_cache),
        "word_timestamps": args.words,
    }
    # OpenVINO GenAI 2026.2 exposes Whisper through WhisperPipeline.  The
    # generic ASRPipeline API was only added in 2026.3.
    pipe = ov_genai.WhisperPipeline(model_path, args.device, **pipeline_options)
    print("Transcribing...", file=sys.stderr, flush=True)
    config = pipe.get_generation_config()
    config.task = "translate" if args.translate else "transcribe"
    config.return_timestamps = args.timestamps or args.words
    config.word_timestamps = args.words
    language = language_token(args.language)
    if language is not None:
        config.language = language

    def emit(text: str) -> None:
        if text:
            print(text, flush=True)
            print(text, file=log, flush=True)

    audio = (
        iter([decode_audio(args.input)]) if args.input is not None
        else microphone_audio(args.source, args.chunk_seconds)
    )
    offset = 0.0
    try:
        with log:
            for samples in audio:
                result = pipe.generate(samples, config)
                emit(result.texts[0].strip())
                if args.timestamps and result.chunks:
                    for chunk in result.chunks:
                        emit(
                            f"[{offset + chunk.start_ts:8.2f} - "
                            f"{offset + chunk.end_ts:8.2f}] {chunk.text.strip()}"
                        )
                if args.words and result.words:
                    for word in result.words:
                        emit(
                            f"[{offset + word.start_ts:8.2f} - "
                            f"{offset + word.end_ts:8.2f}] {word.word.strip()}"
                        )
                offset += len(samples) / SAMPLE_RATE
    except KeyboardInterrupt:
        print("\nStopped transcription.", file=sys.stderr, flush=True)
    finally:
        if args.input is None:
            audio.close()


if __name__ == "__main__":
    main()
