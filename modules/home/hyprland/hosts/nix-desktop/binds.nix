{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for nix-desktop
  # These will be merged with the default binds
  bind = [
    # Add desktop-specific binds here
    # Example: "$modifier SHIFT,A,exec,some-desktop-only-app"
    ## Web Apps ##
    "$modifier SHIFT,G,exec,gtk-launch dev.heppen.webapps.Github8306"
    "$modifier SHIFT,M,exec,gtk-launch dev.heppen.webapps.Messages2354"
    "$modifier SHIFT,R,exec,gtk-launch dev.heppen.webapps.Restream8099"
    "$modifier,E,exec,gtk-launch dev.heppen.webapps.ProtonMail2716"
    "$modifier SHIFT,U,exec,gtk-launch dev.heppen.webapps.Clickup9509"
    "$modifier SHIFT,D,exec,gtk-launch dev.heppen.webapps.Descript5493"
    "$modifier SHIFT,P,exec,gtk-launch dev.heppen.webapps.NixPackages1585"
    "$modifier SHIFT,C,exec,gtk-launch dev.heppen.webapps.ClaudeAI5594"
    "$modifier SHIFT,L,exec,gtk-launch dev.heppen.webapps.GitLab9087"
  ];

  bindm = [
    # Add desktop-specific mouse binds here
  ];
}
