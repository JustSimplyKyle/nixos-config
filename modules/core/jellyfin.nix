{
  config,
  inputs,
  ...
}:
{

  imports = [ inputs.jellarr.nixosModules.default ];

  config.services.jellarr = {
    enable = true;
    user = "jellyfin";
    group = "jellyfin";
    config = {
      version = 1;
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
