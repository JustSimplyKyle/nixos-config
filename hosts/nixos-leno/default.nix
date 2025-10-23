{ pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];
  # Enable ly display manager with matrix animation
  services.displayManager.ly.enable = false;
  services.displayManager.sddm.enable = lib.mkForce false;

  # Sysc-greet display manager (disabled due to build issues)
  services.sysc-greet.enable = false;

  # Keep niri available at system level for ly display manager to detect it
  programs.niri.package = pkgs.niri;

  # Ensure niri session is available to display manager
  services.displayManager.sessionPackages = [ pkgs.niri ];
}
