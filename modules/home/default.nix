{
  inputs,
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  inherit (variables) waybarChoice;

  # New variable system
  barChoice = variables.barChoice or "waybar";
  defaultShell = variables.defaultShell or "zsh";
  useNvidia = variables.useNvidia or false;


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
    ./helix.nix
    ./zellij.nix
    ./eza.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./gtk.nix
    ./htop.nix
    ./kitty.nix
    ./lazygit.nix
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
    ./better-focus.nix
  ]

  ++ [
    ./niri
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

  # Allows usage in other modules for overriding settings
  _module.args = {
    inherit useNvidia;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let overlay_path = ../../overlays; in with builtins;
      map (n: import (overlay_path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (overlay_path + ("/" + n + "/default.nix")))
                  (attrNames (readDir overlay_path)));
  };

}
