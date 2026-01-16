{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.hxrename.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

