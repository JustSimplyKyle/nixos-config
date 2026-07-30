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
  headless = variables.headless;

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
    ./eza.nix
    ./gh.nix
    ./git.nix
    ./helix.nix
    ./htop.nix
    ./lazygit.nix
    ./scripts
    ./starship.nix
    # ./stylix.nix
    ./tealdeer.nix
    ./tmux.nix
    ./xdg.nix
    ./yazi
    ./environment.nix
    ./hxrename.nix
    ./direnv.nix
    ./ssh.nix
    ./wakatime.nix
    # ./zellij.nix
  ]

  ++ lib.optionals (!headless) [
    ./better-focus.nix
    ./cava.nix
    ./emoji.nix
    ./ghostty.nix
    ./gtk.nix
    ./kitty.nix
    ./niri
    ./obs-studio.nix
    ./qt.nix
    ./swappy.nix
    ./virtmanager.nix
    ./vscode.nix
    # ./wlogout
    ./mpv
    ./playlists.nix
  ]

  ++ lib.optionals (defaultShell == "fish") [
    ./fish
    ./fish/fishrc-personal.nix
  ]
  ++ lib.optionals (defaultShell == "zsh") [
    ./zsh
  ]

  ++ lib.optionals (!headless && actualBarChoice == "dms") [
    ./dank-material-shell
  ]
  ++ lib.optionals (!headless && actualBarChoice == "noctalia") [
    ./noctalia-shell
  ]
  ++ lib.optionals (!headless && actualBarChoice == "waybar") [
    waybarChoice
    ./swaync.nix # Only use swaync with waybar
  ]
  ++ [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak.packages = [
    {
      appId = "com.bambulab.BambuStudio";
      origin = "flathub";
    }
  ];

  # Allows usage in other modules for overriding settings
  _module.args = {
    inherit useNvidia;
  };

  # nixpkgs = {
  #   config = {
  #     allowUnfree = true;
  #     allowBroken = true;
  #     allowInsecure = false;
  #   };

  #   overlays =
  #     # Apply each overlay found in the /overlays directory
  #     let overlay_path = ../../overlays; in with builtins;
  #     map (n: import (overlay_path + ("/" + n)))
  #         (filter (n: match ".*\\.nix" n != null ||
  #                     pathExists (overlay_path + ("/" + n + "/default.nix")))
  #                 (attrNames (readDir overlay_path)));
  # };

  home.packages = [
    pkgs.manrope
    pkgs.open-huninn
    pkgs.source-han-sans
  ];

  fonts.fontconfig.enable = true;

  # services.wluma = {
  #   enable = true;

  #   # This translates directly into the config.toml
  #   settings = {
  #     als.webcam = {
  #       video = 0; # This corresponds to /dev/video0
  #       thresholds = {
  #         "0" = "night";
  #         "15" = "dark";
  #         "30" = "dim";
  #         "45" = "normal";
  #         "60" = "bright";
  #         "75" = "outdoors";
  #       };
  #     };

  #     # Choose your capturer based on your Wayland compositor.
  #     # Use 'wlroots' for Sway/Hyprland. Use 'wayland' for Gnome/KDE.
  #     # capturer.wlroots = {};

  #     output.backlight = [
  #       {
  #         name = "eDP-1"; # Change this to your laptop screen's name (check using wlr-randr or hyprctl monitors)
  #         path = "/sys/class/backlight/intel_backlight"; # Verify this path exists! E.g., amdgpu_bl0 for AMD
  #         capturer = "wayland"; # Must match the capturer defined above
  #       }
  #     ];

  #     # We omit the [keyboard.dell] section to fix your second warning.
  #   };
  # };
}
