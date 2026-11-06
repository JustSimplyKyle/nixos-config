{
  config,
  inputs,
  username,
  ...
}:
{

  imports = [ inputs.jellarr.nixosModules.default ];

  config.services.jellarr = {
    enable = true;
    user = username;
    group = "users";
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
    # Run as the main user so media on user-owned drives (e.g. exfat mounts) is writable
    user = username;
    group = "users";
    openFirewall = true; # Optional: Open port 8096 automatically
  };

}
