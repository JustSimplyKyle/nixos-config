{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.services.sysc-greet;

  # Build sysc-greet from source
  sysc-greet = pkgs.buildGoModule rec {
    pname = "sysc-greet";
    version = "unstable-2024-01-15";

    src = pkgs.fetchFromGitHub {
      owner = "Nomadcxx";
      repo = "sysc-greet";
      rev = "main"; # You may want to pin to a specific commit
      sha256 = ""; # Will need to be filled in after first build attempt
    };

    vendorHash = null; # Will need to be filled in after first build attempt

    buildPhase = ''
      go build -o sysc-greet ./cmd/sysc-greet
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/share/sysc-greet
      cp sysc-greet $out/bin/
      cp -r assets/* $out/share/sysc-greet/ || true
    '';

    meta = with lib; {
      description = "A stylish greeter for greetd with Wayland compositor support";
      homepage = "https://github.com/Nomadcxx/sysc-greet";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  # Compositor selection
  compositorCmd =
    if config.wayland.windowManager.hyprland.enable or false then
      "Hyprland"
    else if config.programs.niri.enable or false then
      "niri"
    else if config.programs.sway.enable or false then
      "sway"
    else
      "Hyprland"; # Default fallback

in
{
  options.services.sysc-greet = {
    enable = lib.mkEnableOption "sysc-greet greeter";

    compositor = lib.mkOption {
      type = lib.types.str;
      default = compositorCmd;
      description = "Wayland compositor to use (hyprland, niri, or sway)";
    };

    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Theme to use for sysc-greet";
    };

    border = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Border style for sysc-greet";
    };

    screensaver = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable screensaver in sysc-greet";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure other greeters are disabled when sysc-greet is enabled
    services.displayManager.ly.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;

    # Enable greetd with sysc-greet
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command =
            let
              args = lib.concatStringsSep " " (
                lib.optional (cfg.theme != null) "--theme ${cfg.theme}"
                ++ lib.optional (cfg.border != null) "--border ${cfg.border}"
                ++ lib.optional (!cfg.screensaver) "--screensaver=false"
              );
            in
            "${sysc-greet}/bin/sysc-greet ${args}";
          user = "greeter";
        };
      };
    };

    # Create greeter user
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
      extraGroups = [ "video" ];
    };

    users.groups.greeter = { };

    # Install required dependencies
    environment.systemPackages = with pkgs; [
      sysc-greet
      kitty # Required by sysc-greet
      swww # Required for wallpapers
    ];

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d /var/cache/sysc-greet 0755 greeter greeter -"
      "d /usr/share/sysc-greet 0755 root root -"
    ];
  };
}
