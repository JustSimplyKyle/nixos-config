{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Enable sddm display manager
  services.displayManager.sddm.enable = true;

  # Sysc-greet display manager
  services.sysc-greet.enable = false;

  # Keep niri available at system level for ly display manager to detect it
  programs.niri.package = pkgs.niri;

  # Ensure niri session is available to display manager
  services.displayManager.sessionPackages = [ pkgs.niri ];
}
