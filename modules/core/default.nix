{inputs, ...}: {
  imports = [
    ./boot.nix
    ./doas.nix
    ./flatpak.nix
    ./fonts.nix
    ./greetd.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./packages.nix
    ./printing.nix
    #./sddm.nix    #Disabled for now until can set up per host variables
    ./security.nix
    ./services.nix
    #./starfish.nix  Not sure why this is here, as it's in modules/home
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
