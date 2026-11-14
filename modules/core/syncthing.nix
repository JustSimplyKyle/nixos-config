{
  config,
  username,
  host,
  lib,
  ...
}: let
  variables = import ../../hosts/${host}/variables.nix;
  syncthingEnable = variables.syncthingEnable or false;
  wallpaperEngine = variables.wallpaperEngine or [ ];

  # Hosts with a pinned identity (cert in the repo, key in sops) share the
  # wallpaper folder with every other pinned host
  certFile = ../../hosts/${host}/syncthing-cert.pem;
  pinned = builtins.pathExists certFile;
  otherDevices = removeAttrs (import ./syncthing-devices.nix) [ host ];
in
lib.mkIf (syncthingEnable || wallpaperEngine != [ ]) {
  sops.secrets.syncthing-key = lib.mkIf pinned {
    sopsFile = ../../secrets/syncthing-${host}.yaml;
  };

  services.syncthing = {
    enable = true;
    user = "${username}";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";

    # Keep devices/folders added through the web UI (http://127.0.0.1:8384)
    overrideDevices = false;
    overrideFolders = false;

    cert = lib.mkIf pinned "${certFile}";
    key = lib.mkIf pinned config.sops.secrets.syncthing-key.path;

    settings = lib.mkIf pinned {
      # Dial over Tailscale (MagicDNS hostname), global discovery doesn't work on every network
      devices = lib.mapAttrs (name: id: {
        inherit id;
        addresses = [ "tcp://${name}:22000" "dynamic" ];
      }) otherDevices;
      # Wallpaper Engine assets and wallpapers used by modules/home/wallpaper-engine.nix
      folders.wallpaperengine = {
        path = "/home/${username}/.local/share/wallpaperengine";
        devices = lib.attrNames otherDevices;
      };
    };
  };
}
