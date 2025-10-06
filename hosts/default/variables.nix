{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "username";
  gitEmail = "email@gmail.com";

  # Hyprland Settings
  # ex "monitor=HDMI-A-1, 1920x1080@60,auto,1"
  #
  extraMonitorSettings = "
    monitor = Virtual-1, 1920x1080@60,auto,1
    ";

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
  browser = "vivaldi"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support
  intelID = "PCI:1:0:0";
  nvidiaID = "PCI:0:2:0";

  ## Enable Features Here ##

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Enable Thunar GUI File Manager
  thunarEnable = true;

  # Enable Controller Support For Gaming
  controllerSupportEnable = false;

  # Enable Flutter Development Environment
  flutterdevEnable = false;

  # Enable Stylix System Theming
  stylixEnable = true;

  # Enable Vicinae Launcher
  vicinaeEnable = true;

  # Enable Syncthing File Synchronization
  syncthingEnable = true;

  # Display Manager Options (choose one - add to host's default.nix)
  # services.greetd.enable = true;           # greetd with tuigreet (default)
  # services.displayManager.ly.enable = true; # ly with matrix animation

  # Set Stylix Image
  #stylixImage = ../../wallpapers/AnimeGirlNightSky.jpg;
  stylixImage = ../../wallpapers/nix-wallpaper-stripes-logo.png;
  #stylixImage = ../../wallpapers/beautifulmountainscape.png;
  #stylixImage = ../../wallpapers/mountainscapedark.jpg;
  #stylixImage = ../../wallpapers/Rainnight.jpg;
  #stylixImage = ../../wallpapers/zaney-wallpaper.jpg;

  # Set Waybar
  # Includes alternates such as:
  # Just uncomment the one you want and comment out the others

  #waybarChoice = ../../modules/home/waybar/Jerry-waybars.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-simple.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-curved.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-nekodyke.nix;
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;
  #waybarChoice = ../../modules/home/waybar/waybar-ddubs-2.nix;

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
}
