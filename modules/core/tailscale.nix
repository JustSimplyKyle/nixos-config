{...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "client";
      enable = true;
      extraSetFlags = [ "--accept-dns=false" ]; 
    };
  };
  networking.firewall.checkReversePath = "loose";
}
