{ config, lib, pkgs, ... }:
{

  sops.secrets."wifi_passphrase" = {
    sopsFile = ../../secrets/wifi-passphrase.yaml; 
  };

  services.create_ap.enable = true;

  services.create_ap.settings = {
    INTERNET_IFACE = "enp8s0";
    WIFI_IFACE = "wlp0s20f3";
    SSID = "nixos";
    # 1. Share Method Fix
    SHARE_METHOD = "nat"; 

    PASSPHRASE = "REDACTED";

    # 2. Force 2.4GHz band
    FREQ_BAND = "2.4";
    CHANNEL = "6"; # Standard channels: 1, 6, or 11

    IEEE80211N = "1";
    
    WPA_VERSION = "2";
  };

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl restart create_ap.service
  '';
}
