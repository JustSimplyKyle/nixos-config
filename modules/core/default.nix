{inputs, ...}: {
  imports = [
    ./boot.nix
    ./doas.nix
    ./flatpak.nix
    ./fonts.nix
    #./greetd.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./packages.nix
    ./printing.nix
    ./sddm.nix
    ./security.nix
    ./services.nix
    ./starfish.nix
    ./steam.nix
    ./stylix.nix
    ./syncthing.nix
    ./system.nix
    ./thunar.nix
    ./user.nix
    ./virtualisation.nix
    ./xserver.nix
    inputs.stylix.nixosModules.stylix
  ];
}
