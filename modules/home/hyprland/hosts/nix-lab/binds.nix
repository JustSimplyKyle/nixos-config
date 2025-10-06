{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for nix-lab (ROG Flow Z13)
  # These will be merged with the default binds
  bind = [
    # Add ROG Flow Z13-specific binds here
    # Example: "$modifier SHIFT,A,exec,some-laptop-only-app"
  ];

  bindm = [
    # Add laptop-specific mouse binds here
  ];
}
