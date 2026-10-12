{ config, ... }:
{
  # The CLI and GUI both need the daemon running, even while disconnected.
  services.cloudflare-warp.enable = true;

  # Install the packaged GUI service, including its runtime resource paths.
  # Start it manually when WARP is needed.
  systemd.packages = [ config.services.cloudflare-warp.package ];
}
