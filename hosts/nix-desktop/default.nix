{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Enable sddm display manager
   services.displayManager.sddm.enable = true;

  # Enable niri window manager (commented out - using home-manager instead for better portal integration)
  # programs.niri.enable = true;

  # Keep niri available at system level for ly display manager to detect it
  programs.niri.package = pkgs.niri;

  # Ensure niri session is available to display manager
  services.displayManager.sessionPackages = [ pkgs.niri ];
}
