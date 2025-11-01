{
  config,
  lib,
  pkgs,
  helium-browser,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableExtraBrowsers;
in
{
  config = lib.mkIf enableExtraBrowsers {
    environment.systemPackages = with pkgs; [
      vivaldi # Privacy-focused browser
      brave # Privacy browser with ad blocking
      chromium # Open source Chrome
      google-chrome # Google Chrome
      firefox # Mozilla Firefox
      helium-browser # Helium browser
    ];
  };
}
