{ pkgs, ...}: {
  networking.firewall.checkReversePath = "loose";
  environment.systemPackages = [
    pkgs.kicad
  ];
}
