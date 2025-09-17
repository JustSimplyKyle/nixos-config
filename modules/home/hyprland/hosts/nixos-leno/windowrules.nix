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
    "tile, class:^(dev.heppen.webapps.Github8240)$"
    "tile, class:^(dev.heppen.webapps.Clickup5396)$"
    "tile, class:^(dev.heppen.webapps.NixPackages5244)$"
    "tile, class:^(dev.heppen.webapps.Messages4146)$"
    "tile, class:^(dev.heppen.webapps.Restream8099)$"
    "tile, class:^(dev.heppen.webapps.ProtonMail4649)$"
    "tile, class:^(dev.heppen.webapps.Claude.ai9362)$"
  ];
}
