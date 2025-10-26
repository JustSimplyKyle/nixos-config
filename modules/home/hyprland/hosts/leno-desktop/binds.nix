{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for leno-desktop
  # These will be merged with the default binds
  bind = [
    # Add leno-desktop-specific binds here
  ];

  bindm = [
    # Add leno-desktop-specific mouse binds here
  ];
}
