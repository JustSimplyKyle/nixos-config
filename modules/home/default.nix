{inputs, host, ...}: let
  inherit (import ../../hosts/${host}/variables.nix) waybarChoice;
in {
  imports = [
    ./amfora.nix
    ./bash.nix
    ./bashrc-personal.nix
    ./bat.nix
    ./bottom.nix
    ./btop.nix
    ./cava.nix
    ./dank-material-shell
    ./emoji.nix
    ./eza.nix
    ./fastfetch
    ./fzf.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gtk.nix
    ./htop.nix
    ./hyprland
    ./kitty.nix
    ./lazygit.nix
    ./niri.nix
    ./nvf.nix
    ./nwg-drawer.nix
    ./obs-studio.nix
    ./rofi
    ./qt.nix
    ./scripts
    ./starship.nix
    ./stylix.nix
    ./swappy.nix
    ./swaync.nix
    ./tealdeer.nix
    ./tmux.nix
    ./virtmanager.nix
    ./vscode.nix
    waybarChoice
    ./wlogout
    ./xdg.nix
    ./yazi
    ./zoxide.nix
    ./zsh
    ./environment.nix
  ];
}
