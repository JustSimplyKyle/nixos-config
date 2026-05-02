{...}: {
  services = {
    tailscale = {
      useRoutingFeatures = "client";
      enable = true;
      extraSetFlags = [ "--accept-dns=false" ]; 
    };
  };
  networking.resolvconf.useLocalResolver = false;
  networking.search = [ "taila3e46.ts.net" ];
  networking.firewall.checkReversePath = "loose";
}
