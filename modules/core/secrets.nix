{
  username,
  ...
}: {
  sops.secrets.jellarr-api-key.sopsFile = ../../secrets/jellarr.yaml;

  sops.secrets."opc-ssh" = {
    sopsFile = ../../secrets/opc-ssh.yaml;
    owner = username;
  };

  sops.secrets."wakatime-key" = {
    sopsFile = ../../secrets/wakatime-key.yaml; 
    owner = username;
  };

  sops.secrets."wifi_passphrase" = {
    sopsFile = ../../secrets/wifi-passphrase.yaml;
  };


}

