{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for nix-desktop
  # These will be merged with the default window rules
  windowrule = [
    # Add desktop-specific window rules here
    # Example: "float, class:^(desktop-only-app)$"
    ## Web Apps ##
    "tile, class:^(dev.heppen.webapps.Github8306)$"
    "tile, class:^(dev.heppen.webapps.Descript5493)$"
    "tile, class:^(dev.heppen.webapps.Clickup9509)$"
    "tile, class:^(dev.heppen.webapps.NixPackages1585)$"
    "tile, class:^(dev.heppen.webapps.Messages2354)$"
    "tile, class:^(dev.heppen.webapps.Restream8099)$"
    "tile, class:^(dev.heppen.webapps.ProtonMail2716)$"
    "tile, class:^(dev.heppen.webapps.ClaudeAI5594)$"
  ];
}
