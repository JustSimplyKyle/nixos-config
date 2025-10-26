{
  inputs,
  host,
  lib,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  inherit (variables) waybarChoice;

  # New variable system
  windowManager = variables.windowManager or "hyprland";
  barChoice = variables.barChoice or "waybar";
  defaultShell = variables.defaultShell or "zsh";

  # Legacy variable support (backwards compatibility)
  enableDMS = variables.enableDankMaterialShell or false;
  legacyBarChoice = if enableDMS then "dms" else "waybar";
  actualBarChoice = if variables ? barChoice then barChoice else legacyBarChoice;

in
{
  imports = [
    ./amfora.nix
    ./bash.nix
    ./bashrc-personal.nix
    ./bat.nix
    ./bottom.nix
    ./btop.nix
    ./cava.nix
    ./emoji.nix
    ./eza.nix
    ./fastfetch
    ./fzf.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gtk.nix
    ./htop.nix
    ./kitty.nix
    ./lazygit.nix
    ./nvf.nix
    ./nwg-drawer.nix
    ./obs-studio.nix
    ./rofi
    ./qt.nix
    ./scripts
    ./starship.nix
    ./stylix.nix
    ./swappy.nix
    ./tealdeer.nix
    ./tmux.nix
    ./virtmanager.nix
    ./vscode.nix
    ./wlogout
    ./xdg.nix
    ./yazi
    ./zoxide.nix
    ./environment.nix
  ]

  # Window Manager - conditional import based on windowManager variable
  ++ lib.optionals (windowManager == "niri") [
    ./niri
  ]
  ++ lib.optionals (windowManager == "hyprland") [
    ./hyprland
  ]

  # Shell - conditional import based on defaultShell variable
  ++ lib.optionals (defaultShell == "fish") [
    ./fish
    ./fish/fishrc-personal.nix
  ]
  ++ lib.optionals (defaultShell == "zsh") [
    ./zsh
  ]

  # Bar - conditional import based on barChoice variable
  ++ lib.optionals (actualBarChoice == "dms") [
    ./dank-material-shell
  ]
  ++ lib.optionals (actualBarChoice == "noctalia") [
    ./noctalia-shell
  ]
  ++ lib.optionals (actualBarChoice == "waybar") [
    waybarChoice
    ./swaync.nix # Only use swaync with waybar
  ];
}
