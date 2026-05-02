{
  host,
  pkgs,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) thunarEnable;
in {
  environment.systemPackages = with pkgs; [
    nautilus
    # ffmpegthumbnailer # Need For Video / Image Preview
    # thunar
    # thunar-archive-plugin
    # thunar-volman
  ];
}
