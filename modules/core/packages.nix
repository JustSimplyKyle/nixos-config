{
  pkgs,
  lib,
  zen-browser,
  helium-browser,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) windowManager;
in
{
  programs = {
    neovim = {
      enable = false;
      defaultEditor = false;
    };
    firefox.enable = false; # Firefox is not installed by default
    dconf.enable = true;
    seahorse.enable = true;
    hyprland = lib.mkIf (windowManager == "hyprland") {
      enable = true; # Create desktop file and dependencies if you switch to GUI login MGR
      package = pkgs.hyprland; # Using unstable nixpkgs for latest version
      portalPackage = pkgs.xdg-desktop-portal-hyprland; # Use matching portal version
    };
    hyprlock.enable = lib.mkIf (windowManager == "hyprland") true; # resolve pam issue https://gitlab.com/Zaney/zaneyos/-/issues/164
    fuse.userAllowOther = true;
    mtr.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Virtualization support for GNOME Boxes
  virtualisation.libvirtd.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "cursor"
      "zed"
      "claude"
    ];

  environment.systemPackages = with pkgs; [
    amfora # Fancy Terminal Browser For Gemini Protocol
    appimage-run # Needed For AppImage Support
    bottom # btop like util
    brightnessctl # For Screen Brightness Control
    cmatrix # Matrix Movie Effect In Terminal
    cowsay # Great Fun Terminal Program
    docker-compose # Allows Controlling Docker From A Single File
    duf # Utility For Viewing Disk Usage In Terminal
    dysk # disk usage util
    eza # Beautiful ls Replacement
    ffmpeg # Terminal Video / Audio Editing
    file-roller # Archive Manager
    gdu # graphical disk usage
    gedit # Simple Graphical Text Editor
    gimp # Great Photo Editor
    glxinfo # Needed for inxi -G GPU info
    gping # graphical ping
    tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    htop # Simple Terminal Based System Monitor
    hyprpicker # Color Picker
    eog # For Image Viewing
    alacritty # Terminal Emulator (default for niri)
    fuzzel # Application Launcher (default for niri)
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    mpv # Incredible Video Player
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nitch # small fetch util
    # Nix Language Packages
    nixfmt-rfc-style # Nix Formatter
    nixd # Nix Language Server
    nil # Nix Language Server
    onefetch # shows current build info and stats
    pavucontrol # For Editing Audio Levels & Devices
    pciutils # Collection Of Tools For Inspecting PCI Devices
    picard # For Changing Music Metadata & Getting Cover Art
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    rhythmbox
    ripgrep # Improved Grep
    socat # Needed For Screenshots
    sox # audio support for FFMPEG
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    v4l-utils # Used For Things Like OBS Virtual Camera
    waypaper # backup wallpaper GUI
    wget # Tool For Fetching Files With Links
    xwayland-satellite # Xwayland outside your Wayland compositor
    ytmdl # Tool For Downloading Audio From YouTube
    # Apps
    nemo # File Manager
    nemo-fileroller # Archive Manager Integration For Nemo
    nwg-displays # Manage Displays
    nwg-drawer # drawer GUI
    nwg-look # Look GUI
    rofi-emoji # rofi-emoji-wayland merged into rofi-emoji in nixpkgs-unstable
    vivaldi # Browser
    youtube-music
    # Development Tools
    #code-cursor # AI IDE
    zed-editor # Another AI IDE
    # jdk # Java Development Kit
    claude-code # For native development
    nwg-dock-hyprland
    popsicle
    zen-browser # Zen Browser
    helium-browser # Helium Browser
    teams-for-linux # Video Meetings
    zoom-us # Video Meetings
    telegram-desktop # Messaging App
    vesktop # Discord Alternative
    chromium # Browser
    google-chrome # Browser
    # Note: Flutter and Android development packages are in modules/core/flutter-dev.nix
    # Enable with flutterdevEnable = true in variables.nix
    # Firebase CLI
    # firebase-tools # Temporarily disabled due to build issues with missing package-lock.json
    gum
    gtk3
    gtk4
    localsend
    obsidian
    gamescope
    protonup-qt
    gnome-boxes # Simple VM manager
    quickemu # Fast VM creation tool
    quickgui # Optional GUI for quickemu
  ];
}
