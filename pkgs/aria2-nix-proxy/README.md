# aria2-nix-proxy

A local HTTP binary-cache endpoint that downloads compressed NAR files with
aria2, using up to 16 connections per file. Small cache metadata is fetched
directly. Nix still verifies store object hashes and the upstream signatures;
keep your existing `trusted-public-keys` and signature checks enabled.

## Run

```sh
nix run .#aria2-nix-proxy
```

The default endpoint is `http://127.0.0.1:8123`, forwarding
`https://cache.nixos.org`. In another terminal, use it for a build:

```sh
nix build nixpkgs#hello \
  --option extra-substituters http://127.0.0.1:8123 \
  --option stalled-download-timeout 900
```

In a daemon installation, overriding substituters requires a trusted user or
system configuration. The proxy advertises priority 10 (configurable with
`--priority`) to take precedence over cache.nixos.org's priority 40. For a
controlled comparison use `--option substituters http://127.0.0.1:8123` to
select only the proxy. Already installed store objects won't be downloaded.

The proxy streams completed contiguous pieces to Nix while aria2 downloads the
rest, allowing Nix to display progress. It uses aria2's local authenticated RPC
interface to track completed pieces, with disk buffering disabled so reported
pieces are readable immediately. Parallel connections can still finish pieces
out of order; the proxy waits for gaps before sending later bytes. The total
download timeout is `--download-timeout` (600 seconds by default). A failure
after streaming starts closes the HTTP connection with an incomplete response;
the partial file is never published in the cache.

```sh
aria2-nix-proxy --upstream https://cache.nixos.org \
  --connections 16 --max-downloads 4 \
  --cache-dir /var/cache/aria2-nix-proxy --cache-size-mib 10240
```

Each instance serves one public cache. NAR URLs must be relative `nar/` paths or
absolute URLs under the same upstream cache prefix; cross-origin object storage
and authenticated caches are not supported. This is a binary-cache endpoint,
not an HTTP CONNECT proxy for arbitrary sites, builtins or flake inputs.

Successful downloads are published atomically. Concurrent requests share a
download, and a disk LRU keeps completed objects within the configured size.
Temporary downloads consume additional space (up to `--max-downloads` files).
Objects larger than the size limit are rejected. Small metadata and failures
are not cached. Partial files are deleted on failure; interrupted process
downloads can leave `download-*` directories, removable when the proxy is stopped.

## Persistent setup in Black Don OS

All host configurations import `modules/core/aria2-nix-proxy.nix`. It starts the
proxy at boot with a persistent cache in `/var/cache/aria2-nix-proxy`, orders it
before the Nix daemon, and adds its localhost endpoint to Nix's substituters.
The upstream caches and signing keys stay configured as fallbacks. The fetcher
overlay is also applied to every host's package set, including Home Manager.

Activate the configuration on the desktop with:

```sh
sudo nixos-rebuild switch --flake .#nixos-desktop
systemctl status aria2-nix-proxy
journalctl -u aria2-nix-proxy -f
```

After activation, ordinary builds use the proxy without extra command-line
options. The service uses the defaults of 16 connections per NAR, four concurrent
downloads, and a 10 GiB completed-object cache. It restarts on failure.

## NixOS service example for other configurations

Import the package with `pkgs.callPackage`, as `modules/core/packages.nix` does.
To run it persistently in another configuration (adjust the package path):

```nix
{ pkgs, lib, ... }:
let
  aria2NixProxy = pkgs.callPackage ./pkgs/aria2-nix-proxy.nix { };
in {
  systemd.services.aria2-nix-proxy = {
    description = "aria2 Nix binary-cache proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${aria2NixProxy}/bin/aria2-nix-proxy --cache-dir /var/cache/aria2-nix-proxy";
      DynamicUser = true;
      CacheDirectory = "aria2-nix-proxy";
      Restart = "on-failure";
    };
  };
  nix.settings.substituters = lib.mkBefore [ "http://127.0.0.1:8123" ];
  nix.settings.stalled-download-timeout = 900;
}
```

Retain the upstream cache as a fallback. Rebuilding activates the fetcher
overlay and service configuration.

## Source download overlay

`overlays/aria2-fetchers.nix` modifies the pinned nixpkgs fetchurl builder's
download step and explicitly wires fetchzip to it. Mirror resolution, hash
checks, executable outputs, temporary downloads and post-fetch hooks stay in
the upstream builder. Plain HTTP(S) requests use aria2; custom `curlOpts`,
`curlOptsList`, `NIX_CURL_FLAGS`, authentication hooks and other protocols use
curl. If aria2 fails, the original curl download runs. Bootstrap aria2 is
obtained from an unmodified package set to prevent dependency cycles.

Source downloads print aria2 progress every second, including transferred bytes,
connections, speed and ETA. Use `nix build -L` or `nixos-rebuild --print-build-logs`
to display it. `dcli` rebuild, build and deploy commands enable build logs by default.

No builtin or flake-input downloader is replaced. Derived nixpkgs archive
fetchers benefit when they delegate to these fetchers. Separately imported
package sets need the overlay too.

## Tests

```sh
nix build .#aria2-nix-proxy
```

The package runs local HTTP tests, including actual aria2 segmented transfers,
concurrent request sharing, signature preservation, HTTP errors, range serving,
disk eviction and failed-download cleanup. No Internet access is needed by the tests.
