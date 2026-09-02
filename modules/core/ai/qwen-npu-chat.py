import os
from pathlib import Path

import openvino_genai as ov_genai
from huggingface_hub import snapshot_download
from openvino import Core


streamed_text = False


def stream_text(text: str) -> ov_genai.StreamingStatus:
    global streamed_text
    streamed_text = streamed_text or bool(text)
    print(text, end="", flush=True)
    return ov_genai.StreamingStatus.RUNNING


def main() -> None:
    devices = Core().available_devices
    if not any(device.startswith("NPU") for device in devices):
        available = ", ".join(devices) or "none"
        raise SystemExit(f"OpenVINO cannot see the NPU (available devices: {available})")

    # The -cw model is symmetric, channel-wise INT4 and is published by
    # OpenVINO specifically for NPU inference.  The similarly named model
    # without -cw is asymmetric, group-wise INT4 and can stall NPU compile.
    model_id = os.environ.get(
        "QWEN_NPU_MODEL", "OpenVINO/Qwen3-8B-int4-cw-ov"
    )
    cache_root = Path(
        os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")
    )
    model_cache_name = model_id.replace("/", "--").lower()
    compile_cache = cache_root / "openvino" / "llm" / model_cache_name
    compile_cache.mkdir(parents=True, exist_ok=True)

    print(f"Downloading/checking {model_id}...", flush=True)
    model_path = snapshot_download(repo_id=model_id)
    generate_hint = os.environ.get("QWEN_NPU_GENERATE_HINT", "FAST_COMPILE")
    print(
        f"Compiling {model_id} on NPU with {generate_hint} "
        "(the first run can take several minutes)...",
        flush=True,
    )
    pipe = ov_genai.LLMPipeline(
        model_path,
        "NPU",
        CACHE_DIR=str(compile_cache),
        CACHE_MODE="OPTIMIZE_SPEED",
        MAX_PROMPT_LEN=int(os.environ.get("QWEN_NPU_PROMPT", "1024")),
        MIN_RESPONSE_LEN=int(os.environ.get("QWEN_NPU_RESPONSE", "256")),
        GENERATE_HINT=generate_hint,
    )

    pipe.start_chat()
    print("Ready. Type /quit or press Ctrl-D to unload the model.")
    try:
        while True:
            try:
                prompt = input("\nyou> ").strip()
            except EOFError:
                break
            if prompt in {"/quit", "/exit"}:
                break
            if not prompt:
                continue
            print("qwen> ", end="", flush=True)
            global streamed_text
            streamed_text = False
            result = pipe.generate(
                prompt,
                max_new_tokens=int(os.environ.get("QWEN_NPU_MAX_TOKENS", "32768")),
                streamer=stream_text,
            )
            # Some NPU/GenAI combinations return the decoded result without
            # invoking a Python streamer.  Never discard that output.
            if not streamed_text:
                print(result.texts[0], end="", flush=True)
            print()
    finally:
        pipe.finish_chat()


if __name__ == "__main__":
    main()
