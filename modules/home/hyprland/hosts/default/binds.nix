{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for default
  # These will be merged with the default binds
  bind = [
    # Add default host-specific binds here
  ];

  bindm = [
    # Add default host-specific mouse binds here
  ];
}
