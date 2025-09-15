{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for nixos-leno
  # These will be merged with the default binds
  bind = [
    # Add laptop-specific binds here
    # Example: "$modifier SHIFT,L,exec,some-laptop-only-app"
  ];

  bindm = [
    # Add laptop-specific mouse binds here
  ];
}
