{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
    ./rtl8852bd.nix
  ];

  # Enable sddm display manager
  services.displayManager.sddm.enable = true;

  # Sysc-greet display manager
  services.sysc-greet.enable = false;

  # Keep niri available at system level for ly display manager to detect it
  programs.niri.package = pkgs.niri;

  # Ensure niri session is available to display manager
  services.displayManager.sessionPackages = [ pkgs.niri ];

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/auto-cpufreq --force=performance";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/auto-cpufreq --force=reset";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };
}
