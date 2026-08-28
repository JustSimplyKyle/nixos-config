import argparse
import os

from openai import OpenAI


DEFAULT_MODEL = "OpenVINO/Qwen3.6-35B-A3B-int4-ov"


def stream_reply(client: OpenAI, model: str, messages: list[dict[str, str]]) -> str:
    if "Qwen3.8" in model:
        chat_template_kwargs = {"reasoning_effort": "medium"}
    else:
        chat_template_kwargs = {
            "enable_thinking": True,
            "preserve_thinking": True,
        }

    stream = client.chat.completions.create(
        model=model,
        messages=messages,
        stream=True,
        extra_body={"chat_template_kwargs": chat_template_kwargs},
        tools=[],
    )

    answer: list[str] = []
    printing_reasoning = False
    printing_content = False
    for chunk in stream:
        if not chunk.choices:
            continue
        delta = chunk.choices[0].delta
        reasoning = getattr(delta, "reasoning_content", None)
        content = delta.content
        if reasoning:
            if not printing_reasoning:
                print("reasoning:\n", end="", flush=True)
                printing_reasoning = True
            print(reasoning, end="", flush=True)
        if content:
            if not printing_content:
                if printing_reasoning:
                    print("\n\nanswer:\n", end="", flush=True)
                printing_content = True
            print(content, end="", flush=True)
            answer.append(content)
    print()
    return "".join(answer)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Chat with the local Qwen OpenVINO Model Server"
    )
    parser.add_argument("prompt", nargs="*", help="send one prompt and exit")
    args = parser.parse_args()

    model = os.environ.get("QWEN_MODEL", DEFAULT_MODEL)
    default_port = "8003" if "Qwen3.8" in model else "8001"
    port = os.environ.get("QWEN_PORT", default_port)
    base_url = os.environ.get("QWEN_BASE_URL", f"http://127.0.0.1:{port}/v3")
    client = OpenAI(base_url=base_url, api_key="unused")
    messages: list[dict[str, str]] = []

    if args.prompt:
        messages.append({"role": "user", "content": " ".join(args.prompt)})
        stream_reply(client, model, messages)
        return

    print(f"Connected to {model} at {base_url}. Type /quit or press Ctrl-D.")
    while True:
        try:
            prompt = input("\nyou> ").strip()
        except EOFError:
            print()
            break
        if prompt in {"/quit", "/exit"}:
            break
        if not prompt:
            continue
        messages.append({"role": "user", "content": prompt})
        print("qwen> ", end="", flush=True)
        answer = stream_reply(client, model, messages)
        messages.append({"role": "assistant", "content": answer})


if __name__ == "__main__":
    main()
