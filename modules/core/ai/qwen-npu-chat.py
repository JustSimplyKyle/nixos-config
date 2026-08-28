import os
from pathlib import Path

import openvino_genai as ov_genai
from huggingface_hub import snapshot_download
from openvino import Core


def stream_text(text: str) -> None:
    print(text, end="", flush=True)


def main() -> None:
    devices = Core().available_devices
    if not any(device.startswith("NPU") for device in devices):
        available = ", ".join(devices) or "none"
        raise SystemExit(f"OpenVINO cannot see the NPU (available devices: {available})")

    model_id = os.environ.get("QWEN_NPU_MODEL", "OpenVINO/Qwen3-8B-int4-ov")
    cache_root = Path(
        os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")
    )
    compile_cache = cache_root / "openvino" / "qwen3-8b-npu"
    compile_cache.mkdir(parents=True, exist_ok=True)

    print(f"Loading {model_id} on NPU (the first run downloads and compiles it)...")
    model_path = snapshot_download(repo_id=model_id)
    pipe = ov_genai.LLMPipeline(
        model_path,
        "NPU",
        CACHE_DIR=str(compile_cache),
        CACHE_MODE="OPTIMIZE_SPEED",
        MAX_PROMPT_LEN=int(os.environ.get("QWEN_NPU_PROMPT", "1024")),
        MIN_RESPONSE_LEN=int(os.environ.get("QWEN_NPU_RESPONSE", "256")),
        GENERATE_HINT="BEST_PERF",
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
            pipe.generate(
                prompt,
                max_new_tokens=int(os.environ.get("QWEN_NPU_MAX_TOKENS", "512")),
                streamer=stream_text,
            )
            print()
    finally:
        pipe.finish_chat()


if __name__ == "__main__":
    main()
