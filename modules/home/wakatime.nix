{ inputs, system, nixosConfig, pkgs, lib, ... }:
let
  format = pkgs.formats.ini { };
in
{
  home.packages = [ pkgs.wakatime-cli inputs.wakatime-ls.packages.${pkgs.stdenv.hostPlatform.system}.wakatime-ls ];

  home.file.".wakatime.cfg".source = format.generate ".wakatime.cfg" {
    settings = {
      api_url = "https://hackatime.hackclub.com/api/hackatime/v1";
      api_key_vault_cmd = "cat ${nixosConfig.sops.secrets.wakatime-key.path}";
      heartbeat_rate_limit_seconds = 30;
      debug = true;
    };
  };
  home.file.".wakatime.cfg".force = true;
}
