{ config, lib, pkgs, ... }:
{

  sops.secrets."wifi_passphrase" = {
    sopsFile = ../../secrets/wifi-passphrase.yaml; 
  };
  services.create_ap.enable = true;

  systemd.services.create_ap.serviceConfig.EnvironmentFile = config.sops.secrets."wifi_passphrase".path;

  services.create_ap.settings = {
    INTERNET_IFACE = "enp8s0";
    WIFI_IFACE = "wlp0s20f3";
    SSID = "nixos";

    # 1. Share Method Fix
    SHARE_METHOD = "nat"; 

    # 2. Force 2.4GHz band
    FREQ_BAND = "2.4";
    CHANNEL = "6"; # Standard channels: 1, 6, or 11

    # 3. "Fairly but not too modern codec" -> 802.11n (Wi-Fi 4)
    IEEE80211N = "1";
    
    # Optional: Force WPA2 (Highly secure, but not as "bleeding edge" as WPA3)
    WPA_VERSION = "2";
  };
}
