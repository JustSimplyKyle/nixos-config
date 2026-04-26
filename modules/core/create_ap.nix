{ config, lib, pkgs, ... }:
let
  apInterface    = "wlp0s20f3";
  upstreamInterface = "enp8s0";
in
{
  sops.secrets."wifi_passphrase" = {
    sopsFile = ../../secrets/wifi-passphrase.yaml;
  };

  networking.networkmanager.enable = true;

  networking.networkmanager.wifi.powersave = false;

  # 1. Keep NetworkManager away from the AP radio
  networking.networkmanager.unmanaged = [ "interface-name:${apInterface}" ];

  # 2. Static IP for the AP interface
  networking.interfaces.${apInterface} = {
    ipv4.addresses = [{
        address      = "192.168.12.1";
        prefixLength = 24;
    }];
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", KERNEL=="${apInterface}", RUN+="${pkgs.iw}/bin/iw dev ${apInterface} set power_save off"
  '';

  # 3. NAT + IPv4 forwarding
  networking.nat = {
    enable             = true;
    internalInterfaces = [ apInterface ];
    externalInterface  = upstreamInterface;
  };

  # 4. Firewall: let DHCP and DNS through on the AP side
  networking.firewall.interfaces.${apInterface} = {
    allowedUDPPorts = [ 53 67 ];
    allowedTCPPorts = [ 53 ];
  };

  # 5. dnsmasq — DHCP + DNS for Wi-Fi clients
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      interface        = apInterface;
      except-interface = "lo";
      bind-dynamic     = true;
      listen-address   = "192.168.12.1";

      # Disable dnsmasq's DNS server entirely — Blocky handles DNS
      port = 0;

      dhcp-range = "192.168.12.10,192.168.12.200,24h";

      # Tell Wi-Fi clients to use Blocky for DNS("localhost")
      dhcp-option = "option:dns-server,192.168.12.1";
      domain-needed = true;
      bogus-priv    = true;
    };
  };
  systemd.services."network-addresses-${apInterface}" = {
    after    = [ "hostapd.service" ];
    requires = [ "hostapd.service" ];
    # Force it to re-run if it already ran and failed
    serviceConfig.Restart = "on-failure";
  };

  # dnsmasq still waits for the address (which now waits for hostapd)
  systemd.services.dnsmasq = {
    after    = [ "network-addresses-${apInterface}.service" ];
    requires = [ "network-addresses-${apInterface}.service" ];
  };

  # 6. hostapd
  services.hostapd = {
    enable = true;
    radios.${apInterface} = {
      countryCode = "TW";
      band         = "2g";
      channel      = 6;
      wifi4.enable = true;
      networks.${apInterface} = {
        ssid = "nixos";
        authentication = {
          saePasswords = [
            { passwordFile = config.sops.secrets."wifi_passphrase".path; }
          ];
          # Uncomment for WPA2 fallback (older/picky devices):
          # wpaPasswordFile = config.sops.secrets."wifi_passphrase".path;
        };
      };
    };
  };
}
