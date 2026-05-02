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
      pkgs.vesktop
      # inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.vesktop
    ];
  };
}
