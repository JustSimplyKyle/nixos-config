{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "theblackdon";
  gitEmail = "rj.jones@flosstech.com";

  # Hyprland Settings
  # Configure your monitors here - this is host-specific
  # ex "monitor=HDMI-A-1, 1920x1080@60,auto,1"
  # You'll need to update this after installation based on your actual monitors
  extraMonitorSettings = ''
  monitor=DP-1,3440x1440@180.0,2740x1455,1.0
  monitor=DP-2,1920x1080@60.0,820x1714,1.0
  monitor=DP-3,1920x1080@60.0,6180x1714,1.0
  '';

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "vivaldi"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support (update these IDs after hardware detection)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";   # Update this with your actual integrated GPU ID
  nvidiaID = "PCI:1:0:0";  # Update this with your actual NVIDIA GPU ID

  # Enable/Disable Features
  enableNFS = true; # Enable NFS Support
  printEnable = false; # Enable Printing Support
  thunarEnable = true; # Enable Thunar File Manager
  controllerSupportEnable = true; # Enable Controller Support For Gaming
  flutterdevEnable = true; # Enable Flutter Development Environment
  stylixEnable = true; # Enable Stylix System Theming
  vicinaeEnable = true; # Enable Vicinae Launcher
  syncthingEnable = true; # Enable Syncthing File Synchronization

  # Styling
  stylixImage = ../../wallpapers/black_hole_by_kurzgesagt.png;

  # Waybar Choice
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/animations-end4.nix;
}
