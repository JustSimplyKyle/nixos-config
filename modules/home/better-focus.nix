{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.better-focus.packages.${pkgs.system}.default
  ];
}

