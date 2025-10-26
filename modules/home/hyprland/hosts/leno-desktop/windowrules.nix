{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for leno-desktop
  # These will be merged with the default window rules
  windowrule = [
    # Add leno-desktop-specific window rules here
  ];
}
