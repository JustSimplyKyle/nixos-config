{ config, ... }: {
  sops.secrets."eduroam-env" = {
    sopsFile = ../../secrets/eduroam.env;
    format = "dotenv";
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets."eduroam-env".path ];
    profiles.eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
      };
      wifi = {
        ssid = "eduroam";
        mode = "infrastructure";
      };
      wifi-security.key-mgmt = "wpa-eap";
      "802-1x" = {
        eap = "peap";
        phase2-auth = "mschapv2";
        identity = "B11527018@mail.ntust.edu.tw";
        password = "$EDUROAM_PASSWORD";
        ca-cert = "/etc/ssl/certs/ca-certificates.crt";
        # Only send the password to NTUST's RADIUS server
        domain-suffix-match = "ntust.edu.tw";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
