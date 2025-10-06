{pkgs, ...}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Enable Asus ROG services for keyboard, trackpad, and backlight control
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # Note: supergfxctl is not needed for Intel-only model (no dGPU to switch)

  # Enable greetd display manager
  services.greetd.enable = true;
}
