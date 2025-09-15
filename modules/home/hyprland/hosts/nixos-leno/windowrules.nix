{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for nixos-leno
  # These will be merged with the default window rules
  windowrule = [
    # Add laptop-specific window rules here
    # Example: "size 80% 80%, class:^(laptop-app)$"
  ];
}
