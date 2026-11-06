{
  config,
  lib,
  pkgs,
  host,
  inputs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableCommunicationApps;
in
{
  config = lib.mkIf enableCommunicationApps {
    environment.systemPackages = [
      pkgs.vesktop
    ];

    # Makes Electron apps (including Vesktop) use native Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
