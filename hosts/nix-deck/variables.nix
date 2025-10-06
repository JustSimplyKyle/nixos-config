{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "theblackdon";
  gitEmail = "theblackdonatello@gmail.com";

  # Hyprland Settings
  # Steam Deck display configuration
  # The Steam Deck has a 1280x800 display at 60Hz
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
    fullscreen_on_one_column = false;
    focus_fit_method = 1;
  };

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "io.github.zen_browser.zen"; # Set Default Browser
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Steam Deck uses AMD APU - these IDs are not used
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Enable/Disable Features
  enableNFS = false; # Disabled for portable gaming device
  printEnable = false; # Disabled for portable gaming device
  thunarEnable = true;
  controllerSupportEnable = true; # Enable Controller Support For Gaming

  # Styling
  stylixImage = ../../wallpapers/marvel-gambit.jpg;

  # Waybar Choice
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/animations-end4.nix;

  # Steam Deck Specific Settings
  steamDeckMode = true; # Flag to enable Steam Deck optimizations
}
