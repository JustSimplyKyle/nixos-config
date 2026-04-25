
{ config, pkgs, lib, ... }:
let
  format = pkgs.formats.ini { };
in
{
  sops.secrets."wakatime-key" = {
    sopsFile = ../../secrets/wakatime-key.yaml; 
  };

  home.file.".wakatime.cfg".source = format.generate ".wakatime.cfg" {
    settings = {
      api_url = "https://hackatime.hackclub.com/api/hackatime/v1";
      api_key_vault_cmd = "cat ${config.sops.secrets.wakatime-key.path}";
      heartbeat_rate_limit_seconds = 30;
    };
  };
  home.file.".wakatime.cfg".force = true;
}
