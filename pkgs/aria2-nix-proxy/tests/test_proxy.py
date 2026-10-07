import concurrent.futures
import contextlib
import hashlib
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from http.client import IncompleteRead
import importlib.util
from pathlib import Path
import shutil
import tempfile
import threading
import time
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen


spec = importlib.util.spec_from_file_location("proxy", Path(__file__).resolve().parents[1] / "proxy.py")
proxy = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proxy)
DATA = bytes(range(256)) * (32 * 1024)  # 8 MiB, enough to exercise segmented downloads.
INFO = "/" + "a" * 32 + ".narinfo"
SIGNATURE = b"Sig: cache.example:unchanged-signature\n"


class Upstream(BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.respond(True)

    def do_GET(self):
        self.respond(False)

    def respond(self, head):
        with self.server.guard:
            self.server.requests.append((self.command, self.path, self.headers.get("Range")))
        if self.path == "/nix-cache-info":
            data = b"StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 40\n"
        elif self.path == INFO:
            data = b"StorePath: /nix/store/" + b"a" * 32 + b"-example\nURL: " + self.server.nar_url + b"\n" + SIGNATURE
        elif self.path in ("/nar/object.nar.xz", "/nar/second.nar.xz"):
            data = DATA
        else:
            self.send_error(404)
            return
        start, end = 0, len(data) - 1
        requested = self.headers.get("Range")
        if requested:
            left, right = requested.removeprefix("bytes=").split("-")
            start = int(left)
            end = min(int(right), end) if right else end
        self.send_response(206 if requested else 200)
        self.send_header("Content-Length", str(end - start + 1))
        self.send_header("Accept-Ranges", "bytes")
        if requested:
            self.send_header("Content-Range", f"bytes {start}-{end}/{len(data)}")
        self.end_headers()
        if not head:
            try:
                for offset in range(start, end + 1, 64 * 1024):
                    if self.path.startswith("/nar/") and offset >= 1024 * 1024:
                        self.server.download_gate.wait(timeout=10)
                    self.wfile.write(data[offset:min(offset + 64 * 1024, end + 1)])
                    if self.path.startswith("/nar/"):
                        time.sleep(0.002)
            except (BrokenPipeError, ConnectionResetError):
                pass

    def log_message(self, *args):
        pass


@contextlib.contextmanager
def running(server):
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        yield f"http://127.0.0.1:{server.server_port}"
    finally:
        server.shutdown()
        server.server_close()
        thread.join()


class ProxyTests(unittest.TestCase):
    def setUp(self):
        self.stack = contextlib.ExitStack()
        self.addCleanup(self.stack.close)
        temporary = self.stack.enter_context(tempfile.TemporaryDirectory())
        self.upstream = ThreadingHTTPServer(("127.0.0.1", 0), Upstream)
        self.upstream.requests = []
        self.upstream.guard = threading.Lock()
        self.upstream.download_gate = threading.Event()
        self.upstream.download_gate.set()
        self.addCleanup(self.upstream.download_gate.set)
        self.upstream.nar_url = b"nar/object.nar.xz"
        upstream_url = self.stack.enter_context(running(self.upstream))
        args = proxy.parser().parse_args([
            "--upstream", upstream_url, "--cache-dir", temporary,
            "--cache-size-mib", "10", "--connections", "4", "--download-timeout", "30",
        ])
        self.cache = proxy.Cache(args)
        self.url = self.stack.enter_context(running(proxy.Server(("127.0.0.1", 0), self.cache)))

    def get(self, path, headers=None, method="GET"):
        try:
            with urlopen(Request(self.url + path, headers=headers or {}, method=method), timeout=40) as response:
                return response.status, response.read(), response.headers
        except HTTPError as error:
            error.close()
            raise

    def test_metadata_and_signature(self):
        self.assertIn(b"StoreDir: /nix/store", self.get("/nix-cache-info")[1])
        self.assertIn(b"Priority: 10\n", self.get("/nix-cache-info")[1])
        self.assertIn(SIGNATURE, self.get(INFO)[1])
        self.assertIn(b"URL: nar/object.nar.xz\n", self.get(INFO)[1])
        self.assertEqual(list(self.cache.directory.glob("*.nar")), [])

    def test_absolute_url_rewriting(self):
        self.upstream.nar_url = (self.cache.upstream + "nar/object.nar.xz").encode()
        self.assertIn(b"URL: nar/object.nar.xz\n", self.get(INFO)[1])
        self.assertIn(SIGNATURE, self.get(INFO)[1])

    def test_external_url_rejected(self):
        self.upstream.nar_url = b"https://elsewhere.example/nar/object.nar.xz"
        with self.assertRaises(HTTPError) as error:
            self.get(INFO)
        self.assertEqual(error.exception.code, 502)

    def test_not_found_and_invalid_paths(self):
        for path in ("/" + "b" * 32 + ".narinfo", "/nar/missing.nar.xz", "/nar/../secret", "/nar/%2e%2e/secret", "/nar/file?url=http://example.com", "/etc/passwd"):
            with self.subTest(path=path), self.assertRaises(HTTPError) as error:
                self.get(path)
            self.assertEqual(error.exception.code, 404)

    def test_head_does_not_download(self):
        status, data, headers = self.get("/nar/object.nar.xz", method="HEAD")
        self.assertEqual((status, data, int(headers["Content-Length"])), (200, b"", len(DATA)))
        self.assertEqual([r[0] for r in self.upstream.requests], ["HEAD"])

    @unittest.skipUnless(shutil.which("aria2c"), "aria2c is required for download tests")
    def test_streams_before_download_finishes(self):
        self.upstream.download_gate.clear()
        try:
            with urlopen(self.url + "/nar/object.nar.xz", timeout=5) as response:
                # The upstream blocks every byte beyond the file's first MiB.
                # Receiving bytes now proves we are streaming completed pieces.
                prefix = response.read(1024)
                self.assertEqual(prefix, DATA[:1024])
                self.assertEqual(list(self.cache.directory.glob("*.nar")), [])
                self.upstream.download_gate.set()
                self.assertEqual(prefix + response.read(), DATA)
            # A repeated request waits for atomic publication and uses the cache.
            self.assertEqual(self.get("/nar/object.nar.xz")[1], DATA)
            self.assertEqual(len(list(self.cache.directory.glob("*.nar"))), 1)
        finally:
            self.upstream.download_gate.set()

    @unittest.skipUnless(shutil.which("aria2c"), "aria2c is required for download tests")
    def test_stream_timeout_closes_response_without_publishing(self):
        self.upstream.download_gate.clear()
        self.cache.timeout = 2
        try:
            with urlopen(self.url + "/nar/object.nar.xz", timeout=5) as response:
                self.assertEqual(response.read(1024), DATA[:1024])
                with self.assertRaises(IncompleteRead) as error:
                    response.read()
                self.assertEqual(error.exception.partial, DATA[1024:1024 + len(error.exception.partial)])
            self.assertEqual(list(self.cache.directory.glob("*.nar")), [])
            self.assertEqual(list(self.cache.directory.glob("download-*")), [])
        finally:
            self.upstream.download_gate.set()

    @unittest.skipUnless(shutil.which("aria2c"), "aria2c is required for download tests")
    def test_parallel_download_deduplication_and_ranges(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
            results = list(pool.map(lambda _: self.get("/nar/object.nar.xz")[1], range(3)))
        for data in results:
            self.assertEqual(hashlib.sha256(data).digest(), hashlib.sha256(DATA).digest())
        requests = list(self.upstream.requests)
        # Only one initial download, with multiple nonzero HTTP ranges.
        self.assertEqual(sum(r[0] == "HEAD" for r in requests), 1)
        self.assertGreaterEqual(sum(r[2] is not None for r in requests), 2)
        self.get("/nar/object.nar.xz")
        self.assertEqual(requests, self.upstream.requests)
        status, data, headers = self.get("/nar/object.nar.xz", {"Range": "bytes=42-99"})
        self.assertEqual((status, data), (206, DATA[42:100]))
        self.assertEqual(headers["Content-Range"], f"bytes 42-99/{len(DATA)}")
        self.assertEqual(self.get("/nar/object.nar.xz", {"Range": "bytes=-17"})[1], DATA[-17:])
        with self.assertRaises(HTTPError) as error:
            self.get("/nar/object.nar.xz", {"Range": f"bytes={len(DATA)}-"})
        self.assertEqual(error.exception.code, 416)

    @unittest.skipUnless(shutil.which("aria2c"), "aria2c is required for download tests")
    def test_eviction_preserves_open_reader(self):
        with self.cache.object("/nar/object.nar.xz") as handle:
            self.get("/nar/second.nar.xz")
            self.assertEqual(handle.read(), DATA)
        files = list(self.cache.directory.glob("*.nar"))
        self.assertEqual(len(files), 1)
        self.assertLessEqual(sum(p.stat().st_size for p in files), self.cache.limit)

    def test_failed_download_is_not_published(self):
        self.cache.aria2 = shutil.which("false")
        with self.assertRaises(HTTPError) as error:
            self.get("/nar/object.nar.xz")
        self.assertEqual(error.exception.code, 502)
        self.assertEqual(list(self.cache.directory.glob("*.nar")), [])
        self.assertEqual(list(self.cache.directory.glob("download-*")), [])

    def test_oversized_object_is_rejected(self):
        self.cache.limit = 1
        with self.assertRaises(HTTPError) as error:
            self.get("/nar/object.nar.xz")
        self.assertEqual(error.exception.code, 507)


if __name__ == "__main__":
    unittest.main()
