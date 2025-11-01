{host, lib, ...}: let
  variables = import ../../../hosts/${host}/variables.nix;
  inherit (variables) animChoice;
  enableHyprlock = variables.enableHyprlock or true; # Default to true for backwards compatibility
in {
  imports = [
    animChoice
    ./binds.nix
    ./env.nix
    ./hyprland.nix
    ./pyprland.nix
    ./windowrules.nix
  ]
  # Optional hyprlock and hypridle - can be disabled if using DMS/Noctalia lock screens
  ++ lib.optionals enableHyprlock [
    ./hypridle.nix
    ./hyprlock.nix
  ];
}
