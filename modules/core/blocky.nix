{
  networking.nameservers = [ "127.0.0.1" ];
  networking.networkmanager.dns = "none";
  services.resolved.enable = false;

  services.blocky = {
    enable = true;
    settings = {
      ports = {
        dns = [
          "127.0.0.1:53"
          "192.168.12.1:53"
        ];
        freeBind = true;
      };
      upstreams.groups.default = [
        "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
      ];
      # For initially solving DoH/DoT Requests when no system Resolver is available.
      bootstrapDns = {
        upstream = "https://dns.google/dns-query";
        ips = [
          "8.8.8.8"
          "8.8.4.4"
        ];
      };
      #Enable Blocking of certain domains.
      blocking = {
        denylists = {
          #Adblocking
          ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
        };
        #Configure what block categories are used
        clientGroupsBlock = {
          default = [ "ads" ];
        };
      };
      conditional = {
        mapping = {
          # Ask the Tailscale DNS Resolver (100.100.100.100) to resolve ts.net domains
          "ts.net" = "100.100.100.100";
        };
      };
    };
  };
}
