{
  config,
  lib,
  pkgs,
  host,
  inputs,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableCommunicationApps;
in
{
  config = lib.mkIf enableCommunicationApps {
    environment.systemPackages = [
      inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.vesktop
    ];
  };
}
