{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Steam Deck specific binds
  bind = [
    # Steam button replacement - Super key opens Steam
    "$modifier,S,exec,steam"

    # Quick access to game mode
    "$modifier SHIFT,G,exec,gamescope-session"
  ];

  bindm = [
    # Touch screen friendly mouse binds
  ];
}
