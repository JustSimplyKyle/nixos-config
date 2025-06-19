# SDDM is a display manager for X11 and Wayland
{
  pkgs,
  config,
  lib,
  ...
}: let
  foreground = config.stylix.base16Scheme.base00;
  textColor = config.stylix.base16Scheme.base05;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig =
      if lib.hasSuffix "sakura_static.png" config.stylix.image
      then {}
      else if lib.hasSuffix "studio.png" config.stylix.image
      then {
        Background = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/anotherhadi/nixy-wallpapers/refs/heads/main/wallpapers/studio.gif";
          sha256 = "sha256-qySDskjmFYt+ncslpbz0BfXiWm4hmFf5GPWF2NlTVB8=";
        };
        HeaderTextColor = "#${textColor}";
        DateTextColor = "#${textColor}";
        TimeTextColor = "#${textColor}";
        LoginFieldTextColor = "#${textColor}";
        PasswordFieldTextColor = "#${textColor}";
        UserIconColor = "#${textColor}";
        PasswordIconColor = "#${textColor}";
        WarningColor = "#${textColor}";
        LoginButtonBackgroundColor = "#${foreground}";
        SystemButtonsIconsColor = "#${foreground}";
        SessionButtonTextColor = "#${textColor}";
        VirtualKeyboardButtonTextColor = "#${textColor}";
        DropdownBackgroundColor = "#${foreground}";
        HighlightBackgroundColor = "#${textColor}";
      }
      else {
        Background = "${toString config.stylix.image}";
        HeaderTextColor = "#${textColor}";
        DateTextColor = "#${textColor}";
        TimeTextColor = "#${textColor}";
        LoginFieldTextColor = "#${foreground}";
        PasswordFieldTextColor = "#${foreground}";
        UserIconColor = "#${foreground}";
        PasswordIconColor = "#${foreground}";
        WarningColor = "#${foreground}";
        LoginButtonBackgroundColor = "#${foreground}";
        SystemButtonsIconsColor = "#${foreground}";
        SessionButtonTextColor = "#${textColor}";
        VirtualKeyboardButtonTextColor = "#${textColor}";
        DropdownBackgroundColor = "#${foreground}";
        HighlightBackgroundColor = "#${textColor}";
      };
  };
in {
  services.displayManager = {
    sddm = {
      package = pkgs.kdePackages.sddm;
      extraPackages = [sddm-astronaut];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
    };
  };

  environment.systemPackages = [sddm-astronaut];

  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
