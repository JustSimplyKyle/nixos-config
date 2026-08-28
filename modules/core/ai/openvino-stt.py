import argparse
import array
import os
import subprocess
import sys
from pathlib import Path

import openvino_genai as ov_genai
from huggingface_hub import snapshot_download
from openvino import Core


DEFAULT_MODEL = "OpenVINO/whisper-large-v3-turbo-int8-ov"


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
        description="Transcribe an audio or video file locally with OpenVINO Whisper."
    )
    parser.add_argument("input", type=Path, help="audio or video file to transcribe")
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
    if not args.input.is_file():
        raise SystemExit(f"Input file does not exist: {args.input}")

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

    print(f"Loading {args.model} on {args.device}...", file=sys.stderr)
    model_path = snapshot_download(repo_id=args.model)
    pipeline_options: dict[str, object] = {
        "CACHE_DIR": str(compile_cache),
        "word_timestamps": args.words,
    }
    if args.device.startswith("NPU"):
        pipeline_options["STATIC_PIPELINE"] = True

    pipe = ov_genai.ASRPipeline(model_path, args.device, **pipeline_options)
    config = pipe.get_generation_config()
    config.task = "translate" if args.translate else "transcribe"
    config.return_timestamps = args.timestamps or args.words
    config.word_timestamps = args.words
    language = language_token(args.language)
    if language is not None:
        config.language = language

    result = pipe.generate(decode_audio(args.input), config)
    print(result.texts[0].strip())

    if args.timestamps and result.chunks:
        for chunk in result.chunks[0]:
            print(f"[{chunk.start_ts:8.2f} - {chunk.end_ts:8.2f}] {chunk.text.strip()}")
    if args.words and result.words:
        for word in result.words[0]:
            print(f"[{word.start_ts:8.2f} - {word.end_ts:8.2f}] {word.text.strip()}")


if __name__ == "__main__":
    main()
