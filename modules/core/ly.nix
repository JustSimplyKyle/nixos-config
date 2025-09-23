{ config, lib, pkgs, ... }:
{
  # Ensure greetd is disabled when ly is enabled
  services.greetd.enable = lib.mkIf config.services.displayManager.ly.enable (lib.mkForce false);

  # Enable ly with the Matrix animation
  # Animations: "doom", "colormix", "matrix"
  services.displayManager.ly = {
    enable = lib.mkDefault false;
    settings = {
      animation = "matrix";
      save_file = "/etc/ly/save";
      tty = 2;
      hide_borders = true;
      min_refresh_delta = 5;
    };
  };

}
