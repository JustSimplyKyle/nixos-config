{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for default
  # These will be merged with the default window rules
  windowrule = [
    # Add default host-specific window rules here
  ];
}
