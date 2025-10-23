{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    audacity
    discord
    gamescope
    nodejs
  ];
}
