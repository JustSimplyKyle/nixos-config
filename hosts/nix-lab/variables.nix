{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "theblackdon";
  gitEmail = "rj.jones@flosstech.com";

  # Hyprland Settings
  # Configure your monitors here - this is host-specific
  # ex "monitor=HDMI-A-1, 1920x1080@60,auto,1"
  # ROG Flow Z13 has a 13.4" touch display
  extraMonitorSettings = ''
  monitor=eDP-1,1920x1200@120,0x0,1.0
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
  browser = "zen"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Intel iGPU only (no NVIDIA dGPU on this model)
  # Run 'lspci | grep VGA' after installation to confirm your GPU ID
  intelID = "PCI:0:2:0";   # Update this with your actual integrated GPU ID
  nvidiaID = "";  # No NVIDIA GPU on this model

  # Enable/Disable Features
  enableNFS = false; # Enable NFS Support
  printEnable = false; # Enable Printing Support
  thunarEnable = true; # Enable Thunar File Manager
  controllerSupportEnable = true; # Enable Controller Support For Gaming
  flutterdevEnable = false; # Enable Flutter Development Environment
  stylixEnable = true; # Enable Stylix System Theming
  vicinaeEnable = false; # Enable Vicinae Launcher
  syncthingEnable = true; # Enable Syncthing File Synchronization

  # Display Manager Options (choose one - add to host's default.nix)
  # services.greetd.enable = true;           # greetd with tuigreet (default)
  # services.displayManager.ly.enable = true; # ly with matrix animation

  # Styling
  stylixImage = ../../wallpapers/moon-knight.jpg;

  # Waybar Choice
  waybarChoice = ../../modules/home/waybar/waybar-jak-catppuccin.nix;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/animations-end4.nix;
}
