{
  username,
  host,
  lib,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) syncthingEnable;
in
lib.mkIf syncthingEnable {
  services.syncthing = {
    enable = true;
    user = "${username}";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";
  };
}
