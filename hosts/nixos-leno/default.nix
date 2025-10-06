{pkgs, lib, ...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];
  # Enable ly display manager with matrix animation
  services.displayManager.ly.enable = true;
  services.displayManager.sddm.enable = lib.mkForce false;

  # Keep niri available at system level for ly display manager to detect it
  programs.niri.package = pkgs.niri;

  # Ensure niri session is available to display manager
  services.displayManager.sessionPackages = [ pkgs.niri ];
}
