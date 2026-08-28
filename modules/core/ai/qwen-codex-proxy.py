#!/usr/bin/env python3
"""Small Codex Responses -> OVMS Responses compatibility proxy."""

from __future__ import annotations

import argparse
import http.client
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


UNSUPPORTED_REQUEST_FIELDS = {
    "background",
    "context_management",
    "conversation",
    "include",
    "max_tool_calls",
    "metadata",
    "parallel_tool_calls",
    "previous_response_id",
    "prompt",
    "prompt_cache_key",
    "prompt_cache_retention",
    "safety_identifier",
    "service_tier",
    "store",
    "text",
    "top_logprobs",
    "truncation",
    "user",
}


def _text_from_message(item: dict) -> str:
    content = item.get("content", "")
    if isinstance(content, str):
        return content
    if not isinstance(content, list):
        return ""
    parts = []
    for part in content:
        if isinstance(part, dict) and part.get("type") in {"input_text", "text"}:
            text = part.get("text")
            if isinstance(text, str):
                parts.append(text)
    return "\n\n".join(parts)


def adapt_responses_request(body: dict) -> dict:
    """Convert the small part of Codex's request shape OVMS does not accept."""
    body = dict(body)
    system_parts = []

    instructions = body.pop("instructions", None)
    if isinstance(instructions, str) and instructions:
        system_parts.append(instructions)

    for field in UNSUPPORTED_REQUEST_FIELDS:
        body.pop(field, None)

    input_items = body.get("input")
    if isinstance(input_items, list):
        retained = []
        for item in input_items:
            if isinstance(item, dict) and item.get("type", "message") == "message":
                role = item.get("role")
                if role in {"developer", "system"}:
                    text = _text_from_message(item)
                    if text:
                        system_parts.append(text)
                    continue
            retained.append(item)

        if system_parts:
            retained.insert(
                0,
                {
                    "type": "message",
                    "role": "system",
                    "content": [
                        {"type": "input_text", "text": "\n\n".join(system_parts)}
                    ],
                },
            )
        body["input"] = retained

    tools = body.get("tools", [])
    unsupported_tools = [
        tool.get("type", "<missing>")
        for tool in tools
        if isinstance(tool, dict) and tool.get("type") != "function"
    ]
    if unsupported_tools:
        raise ValueError(
            "OVMS accepts function tools only; disable these Codex tool types: "
            + ", ".join(sorted(set(unsupported_tools)))
        )

    model = str(body.get("model", ""))
    if "Qwen3.6" in model:
        template_kwargs = dict(body.get("chat_template_kwargs") or {})
        template_kwargs["enable_thinking"] = True
        template_kwargs["preserve_thinking"] = True
        body["chat_template_kwargs"] = template_kwargs

    return body


class ProxyHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    upstream = urlsplit("http://127.0.0.1:8001")
    experimental_upstream = urlsplit("http://127.0.0.1:8003")

    def log_message(self, format: str, *args: object) -> None:
        sys.stderr.write("qwen-codex-proxy: " + format % args + "\n")

    def _upstream_connection(self, target) -> http.client.HTTPConnection:
        cls = (
            http.client.HTTPSConnection
            if target.scheme == "https"
            else http.client.HTTPConnection
        )
        return cls(target.hostname, target.port, timeout=600)

    def _target_path(self, target) -> str:
        prefix = target.path.rstrip("/")
        return prefix + self.path

    def _proxy(self, body: bytes | None = None, target=None) -> None:
        target = target or self.upstream
        headers = {
            key: value
            for key, value in self.headers.items()
            if key.lower() not in {"connection", "content-length", "host", "transfer-encoding"}
        }
        if body is not None:
            headers["Content-Length"] = str(len(body))

        upstream = self._upstream_connection(target)
        try:
            upstream.request(self.command, self._target_path(target), body=body, headers=headers)
            response = upstream.getresponse()
            self.send_response(response.status, response.reason)
            for key, value in response.getheaders():
                if key.lower() not in {
                    "connection",
                    "content-length",
                    "transfer-encoding",
                }:
                    self.send_header(key, value)
            self.send_header("Connection", "close")
            self.end_headers()
            while chunk := response.read1(64 * 1024):
                self.wfile.write(chunk)
                self.wfile.flush()
        finally:
            upstream.close()
            self.close_connection = True

    def do_GET(self) -> None:  # noqa: N802
        self._proxy()

    def do_POST(self) -> None:  # noqa: N802
        length = int(self.headers.get("Content-Length", "0"))
        raw_body = self.rfile.read(length)
        target = self.upstream
        if self.path.rstrip("/").endswith("/responses"):
            try:
                parsed = json.loads(raw_body)
                if "Qwen3.8" in str(parsed.get("model", "")):
                    target = self.experimental_upstream
                raw_body = json.dumps(adapt_responses_request(parsed)).encode()
            except (json.JSONDecodeError, TypeError, ValueError) as error:
                response = json.dumps({"error": str(error)}).encode()
                self.send_response(400)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(response)))
                self.end_headers()
                self.wfile.write(response)
                return
        self._proxy(raw_body, target)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--listen", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8011)
    parser.add_argument("--upstream", default="http://127.0.0.1:8001")
    parser.add_argument(
        "--experimental-upstream", default="http://127.0.0.1:8003"
    )
    args = parser.parse_args()

    ProxyHandler.upstream = urlsplit(args.upstream)
    ProxyHandler.experimental_upstream = urlsplit(args.experimental_upstream)
    server = ThreadingHTTPServer((args.listen, args.port), ProxyHandler)
    print(
        f"Qwen Codex adapter listening on http://{args.listen}:{args.port}; "
        f"forwarding to {args.upstream} (Qwen 3.8: {args.experimental_upstream})",
        file=sys.stderr,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
