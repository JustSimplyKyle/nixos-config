{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  services.greetd = lib.mkIf (!config.services.sysc-greet.enable or false) {
    enable = lib.mkDefault (
      !config.services.displayManager.sddm.enable && !config.services.displayManager.ly.enable
    );
    # vt = 3;  # REMOVED: VT is now fixed to VT1 in nixpkgs-unstable
    settings = {
      default_session = {
        user = username;
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
      };
    };
  };
}
