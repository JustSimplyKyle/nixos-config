{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  aria2NixProxy = pkgs.callPackage ../../pkgs/aria2-nix-proxy.nix { };
in
{
  # Use the complete flake source so the overlay's relative imports resolve.
  environment.etc."nix/aria2-overlays.nix".text = ''
    [ (import ${inputs.self}/overlays/aria2-fetchers.nix) ]
  '';

  systemd.services.aria2-nix-proxy = {
    description = "aria2 Nix binary-cache proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    serviceConfig = {
      ExecStart = "${aria2NixProxy}/bin/aria2-nix-proxy --listen 127.0.0.1 --port 8123 --upstream https://cache.nixos.org --cache-dir /var/cache/aria2-nix-proxy";
      DynamicUser = true;
      CacheDirectory = "aria2-nix-proxy";
      CacheDirectoryMode = "0700";
      Restart = "on-failure";
      RestartSec = 3;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  # Start the local cache before the daemon, including on socket activation.
  # A proxy failure still allows Nix to use its other substituters.
  systemd.services.nix-daemon = {
    wants = [ "aria2-nix-proxy.service" ];
    after = [ "aria2-nix-proxy.service" ];
  };

  nix.settings = {
    substituters = lib.mkBefore [ "http://127.0.0.1:8123" ];
    # The proxy finishes downloading a NAR before sending its response.
    stalled-download-timeout = 900;
  };
}
