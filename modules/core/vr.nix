{ pkgs, ... }:

{
  # SteamVR and Proton need both native and 32-bit graphics/Vulkan support.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Gives the headset and Sense controllers the USB permissions expected by
  # Monado/SteamVR/Ignition.
  services.udev.packages = [ pkgs.xr-hardware ];
}
