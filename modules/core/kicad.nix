{ pkgs, ...}: {
  networking.firewall.checkReversePath = "loose";
  environment.systemPackages = [
    pkgs.adwaita-icon-theme
    pkgs.hicolor-icon-theme
    pkgs.kicad
  ];
}
