{ pkgs, lib, ... }: {
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

  # CAP_SYS_NICE lets niri get a high-priority GPU context, so a game can't starve the compositor.
  # overlays/niri-drop-ambient-nice.nix keeps it from leaking to apps niri launches.
  security.wrappers.niri = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_nice+ep";
    source = "${pkgs.niri}/bin/niri";
  };

  # Start the session through the wrapper; drop-in so the packaged niri.service stays intact
  systemd.user.services.niri = {
    overrideStrategy = "asDropin";
    # Don't let NixOS's minimal service PATH replace the session PATH that niri hands to apps
    environment.PATH = lib.mkForce null;
    serviceConfig.ExecStart = [
      ""
      "/run/wrappers/bin/niri --session"
    ];
  };

  # Automatically lower CPU/IO priority of heavy processes (gradle, cargo, compilers, ...)
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    # The CachyOS rules don't cover Rust builds
    extraRules = [
      { name = "cargo"; type = "Heavy_CPU"; }
      { name = "rustc"; type = "Heavy_CPU"; }
    ];
  };

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
