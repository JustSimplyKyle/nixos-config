{ inputs, lib, host, ... }:
let
  # Import variables safely to avoid recursion
  variables = import ../../hosts/${host}/variables.nix;
  headless = variables.headless or false;
  headlessApps = [
    ./boot.nix
    ./flatpak.nix
    ./fonts.nix
    ./nfs.nix
    ./hardware.nix
    ./network.nix
    ./nh.nix
    ./packages.nix
    ./printing.nix
    ./security.nix
    ./services.nix
    ./starfish.nix
    ./syncthing.nix
    ./system.nix
    ./user.nix # home manager stuff
    ./virtualisation.nix
    ./tailscale.nix
    ./blocky.nix
    ./jellyfin.nix
    ./infi75_custom.nix
    ./create_ap.nix
    ./usb-wakeup-disable.nix
    ./altstore.nix
    ./auto-cpufreq.nix
  ];
  guiApps = [
    ./ai-code-editors.nix
    ./browsers-extra.nix
    ./communication.nix
    ./gaming-support.nix
    ./greetd.nix
    ./ly.nix
    ./sddm.nix
    ./sysc-greet.nix
    ./flutter-dev.nix
    ./productivity.nix
    ./steam.nix
    ./thunar.nix
    ./xserver.nix
    ./fcitx5.nix
    ./stylix.nix
    ./sunshine.nix
    inputs.stylix.nixosModules.stylix
  ];
  in
{
  imports = headlessApps ++ lib.optionals (!headless) guiApps;
}
