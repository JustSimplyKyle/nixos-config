{
  config,
  lib,
  pkgs,
  host,
  inputs,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  # Legacy support for enableDankMaterialShell
  enableDMSLegacy = variables.enableDankMaterialShell or false;
  enableDMS = (barChoice == "dms") || enableDMSLegacy;

  cfg = config.programs.dankMaterialShell;

  # Material Symbols Rounded font derivation
  material-symbols-rounded = pkgs.stdenvNoCC.mkDerivation {
    pname = "material-symbols-rounded";
    version = "2024-09-01";

    src = pkgs.fetchurl {
      url = "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf";
      hash = "sha256-1xnyL97ifjRLB+Rub6i1Cx/OPPywPUqE8D+vvwgS/CI=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/fonts/truetype/MaterialSymbolsRounded.ttf
      runHook postInstall
    '';

    meta = with lib; {
      description = "Material Symbols Rounded - Variable icon font by Google";
      homepage = "https://fonts.google.com/icons";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };
in
{
  options.programs.dankMaterialShell = {
    enable = lib.mkEnableOption "Dank Material Shell";
  };

  config = lib.mkIf enableDMS {
    # Disable waybar when DMS is enabled to prevent conflicts
    programs.waybar.enable = lib.mkForce false;

    # Install DankMaterialShell and recommended dependencies
    home.packages = with pkgs; [
      # Quickshell - the shell that runs DMS
      inputs.quickshell.packages.${pkgs.system}.default

      # DMS installer script
      (writeShellScriptBin "dms-install" ''
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🎨 Installing Dank Material Shell"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📦 Installing DMS from GitHub flake..."
        nix profile install github:AvengeMedia/DankMaterialShell
        echo ""
        echo "📦 Installing dgop for system monitoring..."
        nix profile install github:AvengeMedia/dgop
        echo ""
        echo "✅ DMS installed successfully!"
        echo "🚀 Configure it in ~/.config/dms/"
        echo ""
      '')

      # DMS uninstaller script
      (writeShellScriptBin "dms-uninstall" ''
        echo "🗑️  Removing Dank Material Shell..."
        nix profile remove github:AvengeMedia/DankMaterialShell 2>/dev/null || true
        nix profile remove github:AvengeMedia/dgop 2>/dev/null || true
        echo "✅ DMS uninstalled"
      '')

      # DMS launcher script (for manual start or Niri autostart)
      (writeShellScriptBin "dms-start" ''
        echo "🚀 Starting Dank Material Shell..."
        killall -q quickshell 2>/dev/null || true
        sleep 0.5
        quickshell -c DankMaterialShell &
        echo "✅ DMS started"
      '')

      # DMS stop script
      (writeShellScriptBin "dms-stop" ''
        echo "🛑 Stopping Dank Material Shell..."
        killall -q quickshell 2>/dev/null || true
        echo "✅ DMS stopped"
      '')

      # Required fonts for DMS
      material-symbols-rounded # Material Symbols Rounded (Google icon font)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

      # Core utilities (required for DMS functionality)
      wl-clipboard # Clipboard support for Wayland
      cliphist # Clipboard history manager
      brightnessctl # Brightness control
      hyprpicker # Color picker for Hyprland
      matugen # Material Design color generation

      # System monitoring dependencies
      # dgop will be installed via dms-install script since it's not in nixpkgs
      lm_sensors # Hardware temperature monitoring
      pciutils # lspci for GPU detection

      # Network utilities (for WiFi module)
      glib # Provides gdbus command for DBus communication (required for WiFi toggle)
      networkmanager # Network management
      networkmanagerapplet # NM applet for GUI

      # Audio visualization
      cava # Console-based audio visualizer

      # Wayland/Qt support
      qt6.qtwayland # Qt6 Wayland support
      libsForQt5.qt5.qtwayland # Qt5 Wayland support

      # Optional but recommended
      gammastep # Screen temperature adjustment (blue light filter)
    ];

    # Font configuration
    fonts.fontconfig.enable = true;

    # Ensure XDG directories exist for DMS
    xdg.configFile."dms/.keep".text = "";

    # XDG directories are already managed by home-manager's xdg module

    # Warning message in home activation
    home.activation.dmsWarning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo "🎨 Dank Material Shell (DMS) is ENABLED"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "⚠️  Waybar has been automatically disabled"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📦 If not yet installed, run: dms-install"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "🚀 Available commands:"
      $DRY_RUN_CMD echo "   dms-start   - Start DMS manually"
      $DRY_RUN_CMD echo "   dms-stop    - Stop DMS"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📝 For Niri users: Add to ~/.config/niri/config.kdl:"
      $DRY_RUN_CMD echo "   spawn-at-startup \"dms-start\""
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "   (Hyprland users: autostart is already configured)"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "⚙️  Configure at: ~/.config/dms/"
      $DRY_RUN_CMD echo "🗑️  To uninstall: dms-uninstall"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📚 Docs: https://github.com/AvengeMedia/DankMaterialShell"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
    '';
  };
}
