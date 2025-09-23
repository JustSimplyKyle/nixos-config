{...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Enable ly display manager with matrix animation
   services.displayManager.ly.enable = true;

  # Enable niri window manager
  programs.niri.enable = true;
}
