{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableProductivityApps;
in
{
  config = lib.mkIf enableProductivityApps {
    environment.systemPackages = with pkgs; [
      obsidian # Note-taking app
      gnome-boxes # Simple VM manager
      quickemu # Fast VM creation tool
      quickgui # Optional GUI for quickemu
    ];
  };
}
