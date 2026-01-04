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
    environment.systemPackages = with pkgs; [
      inputs.nixpkgs-stable.legacyPackages.${pkgs.system}.vesktop
    ];
  };
}
