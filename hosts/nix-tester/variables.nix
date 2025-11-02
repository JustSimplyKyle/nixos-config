{
  # Git Configuration
  gitUsername = "don";
  gitEmail = "don@nix-tester";

  # Monitor Settings (update after installation for your displays)
  extraMonitorSettings = ''
    monitor=,preferred,auto,1
  '';

  # Hyprland Plugin Settings
  hyprexpoSettings = {
    columns = 2;
    gap_size = 5;
    bg_col = "rgb(111111)";
    workspace_method = "center current";
    skip_empty = true;
    enable_gesture = true;
    gesture_fingers = 3;
    gesture_distance = 300;
    gesture_positive = true;
  };

  hyprscrollingSettings = {
    column_default_width = "onehalf";
    column_widths = "onehalf one";
    fullscreen_on_one_column = true;
    focus_fit_method = 1;
  };

  # Waybar Settings
  clock24h = false;

  # Default Applications
  browser = "zen";
  terminal = "kitty";
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support (update if using nvidia-laptop profile)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Core Features
  enableNFS = false;
  printEnable = false;
  thunarEnable = true;
  stylixEnable = true;

  # Optional Features (disabled for faster initial install)
  # You can enable these later by setting to true and rebuilding
  gamingSupportEnable = false;       # Gaming controllers, gamescope, protonup-qt
  flutterdevEnable = false;          # Flutter development environment
  syncthingEnable = false;           # Syncthing file synchronization
  enableCommunicationApps = false;   # Discord, Teams, Zoom, Telegram
  enableExtraBrowsers = false;       # Vivaldi, Brave, Firefox, Chromium, Helium
  enableProductivityApps = false;    # Obsidian, GNOME Boxes, QuickEmu
  aiCodeEditorsEnable = false;       # Claude-code, gemini-cli, cursor

  # Desktop Environment
  enableHyprlock = true;  # Set to false if using DMS/Noctalia lock screens
  barChoice = "waybar";
  defaultShell = "zsh";

  # Theming
  stylixImage = ../../wallpapers/Valley.jpg;
  waybarChoice = ../../modules/home/waybar/waybar-jerry.nix;
  animChoice = ../../modules/home/hyprland/animations-end4.nix;

  # Startup Applications
  startupApps = [];
}
