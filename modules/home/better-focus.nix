{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.better-focus.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

