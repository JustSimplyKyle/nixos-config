{
  pkgs,
  config,
  host,
  username,
  ...
}:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Steam Deck optimizations
  boot.kernelParams = [
    "amd_iommu=off" # Steam Deck optimization
  ];

  # Auto-login configuration for Steam gamescope session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd gamescope-session";
        user = "don";
      };
      initial_session = {
        command = "gamescope-session";
        user = "don";
      };
    };
  };

  # Disable the greeter on tty1 for auto-login
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Enable Steam and gamescope
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Gaming optimizations
  programs.gamemode.enable = true;

  # Steam Deck controller support
  hardware.steam-hardware.enable = true;

  # Performance governor for gaming
  powerManagement.cpuFreqGovernor = "performance";

  # Networking
  networking.hostName = "nix-deck";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "America/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound
  sound.enable = true;

  # User account
  users.users.don = {
    isNormalUser = true;
    description = "don";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "input"
    ];
  };
}
