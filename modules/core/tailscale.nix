{...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "client";
      enable = true;
    };
  };
  networking.firewall.checkReversePath = "loose";
}
