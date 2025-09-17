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
    ## Web Apps ##
    "$modifier SHIFT,G,exec,gtk-launch dev.heppen.webapps.Github8240"
    "$modifier SHIFT,R,exec,gtk-launch dev.heppen.webapps.Restream8099"
    "$modifier,E,exec,gtk-launch dev.heppen.webapps.ProtonMail4649"
    "$modifier SHIFT,P,exec,gtk-launch dev.heppen.webapps.NixPackages5244"
    "$modifier SHIFT,C,exec,gtk-launch dev.heppen.webapps.Claude.ai9362"
    "$modifier SHIFT,U,exec,gtk-launch dev.heppen.webapps.Clickup5396"
    "$modifier SHIFT,M,exec,gtk-launch dev.heppen.webapps.Messages4146"
  ];

  bindm = [
    # Add laptop-specific mouse binds here
  ];
}
