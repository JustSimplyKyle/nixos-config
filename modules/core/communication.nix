{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableCommunicationApps;
in
{
  config = lib.mkIf enableCommunicationApps {
    environment.systemPackages = with pkgs; [
      teams-for-linux # Video Meetings
      zoom-us # Video Meetings
      telegram-desktop # Messaging App
      vesktop # Discord Alternative
    ];
  };
}
