{...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "client";
      enable = true;
      extraSetFlags = [ "--accept-dns=false" ]; 
    };
  };
  networking.resolvconf.useLocalResolver = false;
  networking.firewall.checkReversePath = "loose";
}
