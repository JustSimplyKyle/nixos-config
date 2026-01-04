{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     helix
   # Add host-specific packages here
  ];
}
