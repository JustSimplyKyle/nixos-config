{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Steam Deck essentials
    steam
    steam-run
    gamescope
    gamemode
    mangohud

    # Controllers and input
    antimicrox

    # System utilities
    htop
    neofetch

    # Basic tools
    git
    vim
    wget
    curl
  ];
}
