{
  config,
  lib,
  pkgs,
  inputs,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  enableNoctalia = barChoice == "noctalia";
in
{
  # Import Noctalia home-manager module at top level
  imports = lib.optionals enableNoctalia [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf enableNoctalia {
    # Disable waybar when Noctalia is enabled
    programs.waybar.enable = lib.mkForce false;

    # Install Noctalia package
    home.packages = [ inputs.noctalia.packages.${pkgs.system}.default ];

    # Enable and configure Noctalia Shell
    programs.noctalia-shell = {
      enable = true;
      settings = {
        # Bar configuration
        bar = {
          position = "top";
          density = "compact";
        };

        # General settings
        general = {
          # Avatar path (optional)
          # avatar = "/path/to/avatar.png";
          radiusRatio = 0.5;
          animSpeed = 200;
          animDisabled = false;
          lockBehavior = "blur";
          language = "en";
        };

        # Location and time settings
        location = {
          name = "Local";
          tempUnit = "fahrenheit";
          timeFormat = "12hr";
          weekNumbering = "iso";
          weatherEnabled = true;
        };

        # Color scheme - use Stylix colors for integration
        colors = {
          scheme = "custom";
          mError = "#${config.lib.stylix.colors.base08}";
          mPrimary = "#${config.lib.stylix.colors.base0D}";
          mSurface = "#${config.lib.stylix.colors.base00}";
          mSurfaceContainer = "#${config.lib.stylix.colors.base01}";
          mSurfaceContainerHigh = "#${config.lib.stylix.colors.base02}";
          mSurfaceContainerHighest = "#${config.lib.stylix.colors.base03}";
          mSurfaceContainerLow = "#${config.lib.stylix.colors.base01}";
          mSurfaceContainerLowest = "#${config.lib.stylix.colors.base00}";
          mOnSurface = "#${config.lib.stylix.colors.base05}";
          mOnSurfaceVariant = "#${config.lib.stylix.colors.base04}";
          mOutline = "#${config.lib.stylix.colors.base03}";
          mOutlineVariant = "#${config.lib.stylix.colors.base02}";
          mInverseSurface = "#${config.lib.stylix.colors.base05}";
        };

        # Audio and brightness settings
        audio = {
          volumeIncrement = 5;
          brightnessIncrement = 5;
        };

        # Notification settings
        notifications = {
          lowUrgency = {
            location = "top-right";
            timeout = 5000;
          };
          normalUrgency = {
            location = "top-right";
            timeout = 10000;
          };
          criticalUrgency = {
            location = "top-right";
            timeout = 0; # No timeout for critical
          };
        };
      };
    };

    # Warning message during activation
    home.activation.noctaliaWarning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo "🌙 Noctalia Shell is ENABLED"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "⚠️  Waybar has been automatically disabled"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📝 Configuration location: ~/.config/noctalia/"
      $DRY_RUN_CMD echo "🎨 Colors are automatically synced with Stylix theme"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📚 Docs: https://docs.noctalia.dev"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
    '';
  };
}
