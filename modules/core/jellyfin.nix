{
  config,
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
let
  optionalGroup = name:
    lib.optionals
    (lib.hasAttr name config.users.groups)
    [config.users.groups.${name}.name];
in
{
  # imports = [
  #   inputs.direnv-instant.homeModules.direnv-instant
  # ];

  imports = [inputs.jellarr.nixosModules.default];



  config.sops.secrets.jellarr-api-key.sopsFile = ../../secrets/jellarr.yaml;

  config.services.jellarr = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    config = {
      base_url = "http://localhost:8096";
      system.enableMetrics = true;
    };
    bootstrap = {
      enable = true;
      apiKeyFile = config.sops.secrets.jellarr-api-key.path;
    };
  };

  config.services.jellyfin = {
    enable = true;
    openFirewall = true; # Optional: Open port 8096 automatically
  };

}

