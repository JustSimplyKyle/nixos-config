{
  pkgs,
  host,
  lib,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixImage stylixEnable;
in
lib.mkIf stylixEnable {
  # Styling Options
  stylix = {
    enable = true;
    image = stylixImage;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-soft.yaml";
    base16Scheme = {
      base00 = "1e1e1e"; # Background
      base01 = "242424"; # Alt Background
      base02 = "303030"; # Selection
      base03 = "5e5c64"; # Comments
      base04 = "9a9996"; # Dark Gray
      base05 = "deddda"; # Text
      base06 = "f6f5f4"; # Light Text
      base07 = "ffffff"; # White
      base08 = "f66151"; # Red
      base09 = "ffbe6f"; # Orange
      base0A = "f9f06b"; # Yellow
      base0B = "8ff0a4"; # Green
      base0C = "93ddef"; # Cyan
      base0D = "3584e4"; # Blue (Adwaita Accent)
      base0E = "9141ac"; # Purple
      base0F = "c061cb"; # Brown/Violet
    };
    polarity = "dark";
    opacity.terminal = 1.0;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
          package = pkgs.instrument-sans;
          name = "Instrument Sans";
      };
      serif = {
          package = pkgs.montserrat;
          name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 15;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
