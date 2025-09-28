{pkgs, pkgs-unstable, lib, ...}: {
  programs = {
    neovim = {
      enable = false;
      defaultEditor = false;
    };
    firefox.enable = false; # Firefox is not installed by default
    dconf.enable = true;
    seahorse.enable = true;
    hyprland.enable = true; #create desktop file and depedencies if you switch to GUI login MGR
    hyprlock.enable = true; #resolve pam issue https://gitlab.com/Zaney/zaneyos/-/issues/164
    fuse.userAllowOther = true;
    mtr.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cursor"
    "zed"
    "flutter"
    "jdk"
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
    gping #graphical ping
    greetd.tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
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
    onefetch #shows current build info and stats
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
    # My apps
    nemo # File Manager
    nemo-fileroller # Archive Manager Integration For Nemo
    nwg-displays # Manage Displays
    nwg-drawer # drawer GUI
    vivaldi # Browser
    youtube-music
    # Unstable Packages
    pkgs-unstable.code-cursor # AI IDE
    pkgs-unstable.zed-editor # Another AI IDE
    pkgs-unstable.flutter # Flutter SDK
    pkgs-unstable.jdk # Java vivalDevelopment Kit
    pkgs-unstable.claude-code # For native development
    pkgs-unstable.nwg-dock-hyprland
    teams-for-linux # Video Meetings
    zoom-us # Video Meetings
    telegram-desktop # Messaging App
    android-studio # Android Studio
    chromium # Browser
    google-chrome # Browser
    # Dev Packages
    androidenv.androidPkgs.platform-tools  # This includes adb
    androidenv.androidPkgs.emulator        # For Android emulator
    androidenv.androidPkgs.ndk-bundle
    # Firebase CLI
    firebase-tools
    quick-webapps
    gum
    gtk3
    gtk4
    localsend
    obsidian
    kdePackages.kmag
  ];
}
