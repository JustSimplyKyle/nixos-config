{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "user";
  gitEmail = "user@example.com";

  # Hyprland Settings
  # ex "monitor=HDMI-A-1, 1920x1080@60,auto,1"
  # Configure your monitors here - this is host-specific
  extraMonitorSettings = ''
    monitor=,preferred,auto,1
  '';

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "zen"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0"; # Update with your integrated GPU ID
  nvidiaID = "PCI:1:0:0"; # Update with your NVIDIA GPU ID

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Enable Thunar GUI File Manager
  thunarEnable = true;

  # Enable Gaming Support (controllers, gamescope, protonup-qt)
  gamingSupportEnable = false;

  # Enable Flutter Development Environment
  flutterdevEnable = false;

  # Enable Stylix System Theming
  stylixEnable = true;

  # Enable Syncthing File Synchronization
  syncthingEnable = false;

  # Enable Communication Apps (Teams, Zoom, Telegram, Discord)
  enableCommunicationApps = false;

  # Enable Extra Browsers (Chromium, Google Chrome)
  enableExtraBrowsers = false;

  # Enable Productivity Apps (Obsidian, GNOME Boxes, QuickEmu)
  enableProductivityApps = false;

  # Enable AI Code Editors (cursor, claude-code, gemini-cli)
  aiCodeEditorsEnable = false;

  # Enable Hyprlock (Hyprland lock screen)
  # Set to false if using DMS or Noctalia lock screens
  enableHyprlock = true;

  # Bar/Shell Choice
  barChoice = "dms"; # Options: "dms", "noctalia", or "waybar"

  # Shell Choice
  defaultShell = "zsh"; # Options: "fish" or "zsh"

  # Set Stylix Image
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  #stylixImage = ../../wallpapers/nix-wallpaper-stripes-logo.png;
  #stylixImage = ../../wallpapers/beautifulmountainscape.png;
  #stylixImage = ../../wallpapers/mountainscapedark.jpg;
  #stylixImage = ../../wallpapers/Rainnight.jpg;
  #stylixImage = ../../wallpapers/zaney-wallpaper.jpg;
  stylixImage = ../../wallpapers/55.png;

  # Set Waybar
  # Includes alternates such as:
  # Just uncomment the one you want and comment out the others

  #waybarChoice = ../../modules/home/waybar/Jerry-waybars.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-jerry.nix;
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

  # Set Animation style
  # Available options are:
  # animations-def.nix  (standard)
  # animations-end4.nix (end-4 project)
  # animations-dynamic.nix (ml4w project)
  # animations-moving.nix (ml4w project)
  # Just change the name after the - and rebuild
  animChoice = ../../modules/home/hyprland/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations-dynamix.nix;
  #  Note: Moving changes window resizing it shrinks then pops back
  #animChoice = ../../modules/home/hyprland/animations-moving.nix;

  # Startup Applications
  startupApps = [
  ];
}
