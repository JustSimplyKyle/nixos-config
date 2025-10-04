{ config, lib, pkgs, username, ... }:
{
  services.greetd = {
    enable = lib.mkDefault (!config.services.displayManager.sddm.enable && !config.services.displayManager.ly.enable);
    vt = 3;
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
      };
    };
  };
}
