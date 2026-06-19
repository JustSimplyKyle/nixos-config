{
  # Git Configuration
  gitUsername = "kyle";
  gitEmail = "kyle@nixos-desktop";

  # System Configuration
  timeZone = "Asia/Taipei";

  # Waybar Settings
  clock24h = false;

  # Default Applications
  browser = "helium";
  terminal = "ghostty";
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support (update if using nvidia-laptop profile)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Core Features
  enableNFS = false;
  printEnable = true;
  thunarEnable = true;
  stylixEnable = true;

  # Optional Features (disabled for faster initial install)
  # You can enable these later by setting to true and rebuilding
  gamingSupportEnable = true;       # Gaming controllers, gamescope, protonup-qt
  flutterdevEnable = false;          # Flutter development environment
  syncthingEnable = false;           # Syncthing file synchronization
  enableCommunicationApps = true;   # Discord, Teams, Zoom, Telegram
  enableExtraBrowsers = false;       # Vivaldi, Brave, Firefox, Chromium, Helium
  enableProductivityApps = false;    # Obsidian, GNOME Boxes, QuickEmu
  aiCodeEditorsEnable = true;       # Claude-code, gemini-cli

  # Desktop Environment
  enableHyprlock = false;  # Set to false if using DMS/Noctalia lock screens

  # Bar/Shell Choice
  barChoice = "noctalia";      # Options: "dms" or "noctalia"
  # NOTE: If you change barChoice to "dms", you must run 'dms-install' after rebuilding

  # Shell Choice
  defaultShell = "zsh";   # Options: "fish" or "zsh"


  enableJellyfin = true;

  headless = false;
  enablePowerSaving = false;

  
  # Theming
  stylixImage = ../../wallpapers/Valley.jpg;
}
