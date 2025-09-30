{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Steam Deck specific window rules
  windowrule = [
    # Steam in big picture mode should be fullscreen
    "fullscreen, title:^(Steam Big Picture Mode)$"
    "fullscreen, class:^(steam)$,title:^(Steam)$"

    # Games should be fullscreen
    "fullscreen, class:^(steam_app_.*)$"
  ];
}
