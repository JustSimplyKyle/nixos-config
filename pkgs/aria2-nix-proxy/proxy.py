"""Serve a public Nix binary cache locally, downloading NARs with aria2."""

import argparse
import contextlib
import fcntl
import hashlib
import json
import logging
import os
from pathlib import Path
import re
import shutil
import secrets
import socket
import subprocess
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin, urlsplit
from urllib.request import Request, urlopen


LOG = logging.getLogger("aria2-nix-proxy")
NARINFO = re.compile(r"/[0-9abcdfghijklmnpqrsvwxyz]{32}\.narinfo")
NAR = re.compile(r"/nar/[A-Za-z0-9_./-]+")
RANGE = re.compile(r"bytes=(\d*)-(\d*)")


class ProxyError(Exception):
    def __init__(self, status, message):
        super().__init__(message)
        self.status = status


class Download:
    """Read only the contiguous prefix aria2 reports as completed pieces."""

    def __init__(self, process, path, port, secret, gid, timeout, limit):
        self.process = process
        self.path = path
        self.url = f"http://127.0.0.1:{port}/jsonrpc"
        self.secret = secret
        self.gid = gid
        self.deadline = time.monotonic() + timeout
        self.limit = limit
        self.size = 0
        self.available = 0
        self.complete = False
        self.position = 0
        self.handle = None

    def update(self):
        if time.monotonic() >= self.deadline:
            raise ProxyError(504, "aria2 download timed out")
        if self.process.poll() is not None:
            raise ProxyError(502, "aria2 exited before completing the download")
        payload = json.dumps({"jsonrpc": "2.0", "id": "progress",
                              "method": "aria2.tellStatus",
                              "params": ["token:" + self.secret, self.gid,
                                         ["status", "totalLength", "pieceLength", "bitfield"]]}).encode()
        try:
            with urlopen(Request(self.url, data=payload, headers={"Content-Type": "application/json"}),
                         timeout=min(2, max(0.01, self.deadline - time.monotonic()))) as response:
                reply = json.load(response)
        except (URLError, TimeoutError, OSError):
            # The RPC listener may still be starting. The deadline bounds retries.
            return
        if "error" in reply:
            raise ProxyError(502, "aria2 progress request failed")
        status = reply["result"]
        if status["status"] in ("error", "removed"):
            raise ProxyError(502, "aria2 download failed")
        self.size = int(status["totalLength"])
        if self.size > self.limit:
            raise ProxyError(507, "NAR exceeds cache size; increase --cache-size-mib")
        self.complete = status["status"] == "complete"
        if self.complete:
            if not self.path.is_file() or self.path.stat().st_size != self.size:
                raise ProxyError(502, "aria2 produced an incomplete file")
            self.available = self.size
        else:
            pieces = 0
            for byte in bytes.fromhex(status.get("bitfield", "")):
                for bit in range(7, -1, -1):
                    if not byte & (1 << bit):
                        self.available = min(pieces * int(status["pieceLength"]), self.size)
                        return
                    pieces += 1
            # Hold the final byte until aria2 confirms successful completion.
            self.available = min(pieces * int(status.get("pieceLength", "0")), max(0, self.size - 1))

    def initialize(self):
        while not self.size and not self.complete:
            self.update()
            if not self.size and not self.complete:
                time.sleep(0.1)

    def seek(self, position):
        self.position = position

    def read(self, length=-1):
        if length < 0:
            blocks = []
            while self.position < self.size:
                blocks.append(self.read(1024 * 1024))
            return b"".join(blocks)
        if self.position >= self.size:
            return b""
        while self.available <= self.position:
            self.update()
            if self.available <= self.position:
                time.sleep(0.1)
        if self.handle is None:
            self.handle = self.path.open("rb", buffering=0)
        self.handle.seek(self.position)
        data = self.handle.read(min(length, self.available - self.position))
        if not data:
            raise ProxyError(502, "aria2 completed pieces are missing from disk")
        self.position += len(data)
        return data

    def finish(self):
        while not self.complete:
            self.update()
            if not self.complete:
                time.sleep(0.1)

    def close(self):
        if self.handle is not None:
            self.handle.close()
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait()


def valid_path(path):
    return bool(
        path == "/nix-cache-info"
        or NARINFO.fullmatch(path)
        or (NAR.fullmatch(path) and all(p not in ("", ".", "..") for p in path[1:].split("/")))
    )


class Cache:
    def __init__(self, args):
        self.upstream = args.upstream.rstrip("/") + "/"
        parsed = urlsplit(self.upstream)
        if (
            parsed.scheme not in ("http", "https")
            or not parsed.hostname
            or parsed.username is not None
            or parsed.password is not None
            or parsed.query
            or parsed.fragment
        ):
            raise ValueError("upstream must be a public HTTP(S) cache URL without credentials, query or fragment")
        self.directory = Path(args.cache_dir).expanduser().resolve()
        self.directory.mkdir(parents=True, exist_ok=True, mode=0o700)
        self.aria2 = args.aria2
        self.connections = args.connections
        self.limit = args.cache_size_mib * 1024 * 1024
        self.timeout = args.download_timeout
        self.priority = args.priority
        self.slots = threading.BoundedSemaphore(args.max_downloads)
        # Lock files are striped to bound their number, including across restarts.
        self.lock_directory = self.directory / "locks"
        self.lock_directory.mkdir(exist_ok=True)

    def url(self, path):
        return self.upstream + path.lstrip("/")

    @contextlib.contextmanager
    def lock(self, name):
        with (self.lock_directory / name).open("a") as handle:
            fcntl.flock(handle, fcntl.LOCK_EX)
            yield

    def metadata(self, path, method="GET"):
        request = Request(self.url(path), method=method, headers={"User-Agent": "aria2-nix-proxy/0.1"})
        try:
            with urlopen(request, timeout=30) as response:
                data = response.read(1024 * 1024 + 1) if method == "GET" else b""
                if len(data) > 1024 * 1024:
                    raise ProxyError(502, "upstream metadata exceeds 1 MiB")
                headers = dict(response.headers)
        except HTTPError as error:
            error.close()
            raise ProxyError(error.code, "upstream returned HTTP " + str(error.code)) from error
        except (URLError, TimeoutError, OSError) as error:
            raise ProxyError(502, "upstream metadata request failed") from error

        if method == "GET" and path == "/nix-cache-info":
            lines = [line for line in data.splitlines() if not line.startswith(b"Priority:")]
            data = b"\n".join(lines) + f"\nPriority: {self.priority}\n".encode()
        if method == "GET" and NARINFO.fullmatch(path):
            # URLs are not part of a narinfo signature. Preserve every other
            # byte, especially StorePath, NarHash, References, and Sig.
            lines = data.splitlines(keepends=True)
            for index, line in enumerate(lines):
                if line.startswith(b"URL: "):
                    try:
                        location = line[5:].strip().decode("ascii")
                        absolute = urljoin(self.upstream, location)
                        base = urlsplit(self.upstream)
                        target = urlsplit(absolute)
                        if (
                            (target.scheme, target.netloc) != (base.scheme, base.netloc)
                            or not target.path.startswith(base.path)
                            or target.query
                            or target.fragment
                        ):
                            raise ValueError("external NAR URL")
                        relative = "/" + target.path[len(base.path):]
                        if not NAR.fullmatch(relative) or not valid_path(relative):
                            raise ValueError("unsupported NAR path")
                    except (UnicodeError, ValueError) as error:
                        raise ProxyError(502, "cache uses an unsupported NAR URL (requires same-origin nar/ paths)") from error
                    ending = b"\r\n" if line.endswith(b"\r\n") else b"\n"
                    lines[index] = b"URL: " + relative.lstrip("/").encode("ascii") + ending
            data = b"".join(lines)
        return data, headers

    def prune(self, keep):
        objects = list(self.directory.glob("*.nar"))
        total = sum(p.stat().st_size for p in objects)
        for path in sorted(objects, key=lambda p: p.stat().st_mtime):
            if total <= self.limit:
                break
            if path != keep:
                total -= path.stat().st_size
                path.unlink()

    @contextlib.contextmanager
    def object(self, path):
        key = hashlib.sha256(self.url(path).encode()).hexdigest()
        destination = self.directory / (key + ".nar")
        # A second request waits for publication instead of starting another
        # download. The limit and per-key locks also work across processes.
        with self.lock(key[:2]):
            with self.lock("index"):
                if destination.exists():
                    handle = destination.open("rb")
                    os.utime(destination, None)
                else:
                    handle = None
            if handle is None:
                with self.slots:
                    # Preserve HTTP failures (notably 404) before invoking aria2.
                    try:
                        _, headers = self.metadata(path, method="HEAD")
                    except ProxyError as error:
                        if error.status not in (405, 501):
                            raise
                        headers = {}
                    length = next((v for k, v in headers.items() if k.lower() == "content-length"), None)
                    if length is not None and int(length) > self.limit:
                        raise ProxyError(507, "NAR exceeds cache size; increase --cache-size-mib")
                    with tempfile.TemporaryDirectory(prefix="download-", dir=self.directory) as temporary:
                        with socket.socket() as listener:
                            listener.bind(("127.0.0.1", 0))
                            port = listener.getsockname()[1]
                        secret = secrets.token_hex(32)
                        gid = secrets.token_hex(8)
                        command = [
                            self.aria2, "--no-conf", "--no-netrc", "--enable-rpc=true",
                            "--rpc-listen-all=false", "--rpc-listen-port=" + str(port),
                            "--rpc-secret=" + secret, "--gid=" + gid,
                            "--disk-cache=0",
                            "--split=" + str(self.connections),
                            "--max-connection-per-server=" + str(self.connections),
                            "--stream-piece-selector=inorder",
                            "--min-split-size=1M", "--file-allocation=none",
                            "--auto-file-renaming=false", "--allow-overwrite=true",
                            "--check-certificate=true", "--max-tries=3", "--retry-wait=1",
                            "--connect-timeout=15", "--timeout=60",
                            "--summary-interval=0", "--console-log-level=warn",
                            "--download-result=hide", "--enable-color=false",
                            "--follow-metalink=false", "--follow-torrent=false",
                            "--dir=" + temporary, "--out=object", "--", self.url(path),
                        ]
                        LOG.info("downloading %s with up to %s connections", path, self.connections)
                        try:
                            process = subprocess.Popen(command, stdout=subprocess.DEVNULL)
                        except OSError as error:
                            raise ProxyError(502, "could not start aria2") from error
                        downloaded = Path(temporary) / "object"
                        stream = Download(process, downloaded, port, secret, gid, self.timeout, self.limit)
                        try:
                            stream.initialize()
                            yield stream
                            stream.finish()
                            with self.lock("index"):
                                downloaded.replace(destination)
                                self.prune(destination)
                        finally:
                            stream.close()
                        return
        # An open descriptor survives LRU eviction while another request reads.
        try:
            yield handle
        finally:
            handle.close()


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def do_HEAD(self):
        self.respond(head=True)

    def do_GET(self):
        self.respond(head=False)

    def respond(self, head):
        self.response_started = False
        parsed = urlsplit(self.path)
        path = parsed.path
        if parsed.scheme or parsed.netloc or parsed.query or parsed.fragment or not valid_path(path):
            self.send_error(404, "unsupported cache path")
            return
        try:
            if NAR.fullmatch(path) and not head:
                with self.server.cache.object(path) as handle:
                    size = handle.size if isinstance(handle, Download) else os.fstat(handle.fileno()).st_size
                    start, end, status = 0, size - 1, 200
                    requested = self.headers.get("Range")
                    if requested:
                        match = RANGE.fullmatch(requested)
                        if not match or not any(match.groups()):
                            raise ProxyError(416, "unsupported range")
                        left, right = match.groups()
                        if left:
                            start = int(left)
                            end = min(int(right), size - 1) if right else size - 1
                        else:
                            start = max(0, size - int(right))
                        if start > end or start >= size:
                            self.send_response(416)
                            self.send_header("Content-Range", "bytes */" + str(size))
                            self.send_header("Content-Length", "0")
                            self.end_headers()
                            return
                        status = 206
                    self.send_response(status)
                    self.send_header("Content-Type", "application/octet-stream")
                    self.send_header("Content-Length", str(end - start + 1))
                    self.send_header("Accept-Ranges", "bytes")
                    if status == 206:
                        self.send_header("Content-Range", f"bytes {start}-{end}/{size}")
                    self.end_headers()
                    self.response_started = True
                    handle.seek(start)
                    remaining = end - start + 1
                    while remaining:
                        block = handle.read(min(1024 * 1024, remaining))
                        if not block:
                            break
                        self.wfile.write(block)
                        remaining -= len(block)
                return

            # GET narinfo fresh each time; negative responses must not be kept.
            # HEAD NAR never triggers a full download.
            data, headers = self.server.cache.metadata(path, "HEAD" if head else "GET")
            self.send_response(200)
            for name, value in headers.items():
                if name.lower() in ("content-type", "last-modified"):
                    self.send_header(name, value)
            if head:
                length = next((v for k, v in headers.items() if k.lower() == "content-length"), None)
                if length is not None:
                    self.send_header("Content-Length", length)
            else:
                self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            if not head:
                self.wfile.write(data)
        except ProxyError as error:
            if self.response_started:
                LOG.warning("stream failed for %s: %s", path, error)
                self.close_connection = True
            else:
                self.send_error(error.status, str(error))
        except (BrokenPipeError, ConnectionResetError):
            pass
        except (OSError, ValueError) as error:
            LOG.exception("request failed: %s", path)
            if self.response_started:
                self.close_connection = True
            else:
                self.send_error(502, "proxy request failed")

    def log_message(self, fmt, *args):
        LOG.info("%s " + fmt, self.client_address[0], *args)


class Server(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address, cache):
        super().__init__(address, Handler)
        self.cache = cache


def parser():
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--upstream", default="https://cache.nixos.org")
    result.add_argument("--listen", default="127.0.0.1")
    result.add_argument("--port", type=int, default=8123)
    result.add_argument("--cache-dir", default=os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache")) + "/aria2-nix-proxy")
    result.add_argument("--cache-size-mib", type=int, default=10240)
    result.add_argument("--connections", type=int, choices=range(1, 17), default=16, metavar="1..16")
    result.add_argument("--max-downloads", type=int, default=4)
    result.add_argument("--download-timeout", type=int, default=600, help="total seconds allowed per NAR")
    result.add_argument("--priority", type=int, default=10, help="Nix cache priority; lower values are preferred")
    result.add_argument("--aria2", default=os.environ.get("ARIA2_NIX_PROXY_ARIA2", "aria2c"))
    return result


def main():
    options = parser()
    args = options.parse_args()
    if min(args.max_downloads, args.cache_size_mib, args.download_timeout) < 1:
        options.error("download count, cache size and timeout must be positive")
    if not 0 <= args.port <= 65535:
        options.error("port must be between 0 and 65535")
    if shutil.which(args.aria2) is None:
        options.error("aria2 executable not found: " + args.aria2)
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    try:
        cache = Cache(args)
    except ValueError as error:
        options.error(str(error))
    with Server((args.listen, args.port), cache) as server:
        LOG.info("serving %s at http://%s:%s", cache.upstream, *server.server_address)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
