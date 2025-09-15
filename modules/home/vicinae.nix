{
  inputs,
  lib,
  config,
  host,
  username,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) vicinaeEnable;
in {
  config = lib.mkIf vicinaeEnable {
    home.packages = [
      inputs.vicinae.packages.${config.nixpkgs.system}.default
    ];

    # Note: Vicinae doesn't provide a home-manager service module
    # The application can be launched manually or via desktop files
  };
}
