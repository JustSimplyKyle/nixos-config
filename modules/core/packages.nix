{
  pkgs,
  lib,
  helium-browser,

  host,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  headless = variables.headless or false;
in
{
  programs = {
    neovim = {
      enable = false;
      defaultEditor = false;
    };
    dconf.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # GUI specific programs
    seahorse.enable = !headless;
    hyprlock.enable = !headless;
  };

  virtualisation.libvirtd.enable = true;

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
    gdu # graphical disk usage (TUI)
    gping # graphical ping (TUI)
    gum # Shell scripting tool
    htop # Simple Terminal Based System Monitor
    inxi # CLI System Information Tool
    killall # For Killing All Instances Of Programs
    libnotify # For Notifications (useful even in scripts)
    lm_sensors # Used For Getting Hardware Temps
    lolcat # Add Colors To Your Terminal Command Output
    lshw # Detailed Hardware Information
    ncdu # Disk Usage Analyzer With Ncurses Interface
    nitch # small fetch util
    onefetch # shows current build info and stats
    pciutils # Collection Of Tools For Inspecting PCI Devices
    pkg-config # Wrapper Script For Allowing Packages To Get Info On Others
    playerctl # Allows Changing Media Volume Through Scripts
    ripgrep # Improved Grep
    socat # Needed For Screenshots / networking
    sox # audio support for FFMPEG
    unrar # Tool For Handling .rar Files
    unzip # Tool For Handling .zip Files
    usbutils # Good Tools For USB Devices
    v4l-utils # Used For Things Like OBS Virtual Camera
    wget # Tool For Fetching Files With Links
    ytmdl # Tool For Downloading Audio From YouTube
    pkgs.android-tools
    (callPackage ../../pkgs/mv-merge.nix {})

    # Nix Language Packages
    nixfmt
    nixd # Nix Language Server
    nil # Nix Language Server
  ] ++ lib.optionals (!headless) [
    feishin
    motrix
    feishin
    file-roller # Archive Manager
    gedit # Simple Graphical Text Editor
    gimp # Great Photo Editor
    mesa-demos # Needed for inxi -G GPU info
    tuigreet # The Login Manager
    hyprpicker # Color Picker
    eog # For Image Viewing
    alacritty # Terminal Emulator (default for niri)
    fuzzel # Application Launcher (default for niri)
    mpv # Incredible Video Player
    pavucontrol # For Editing Audio Levels & Devices
    picard # For Changing Music Metadata & Getting Cover Art
    rhythmbox
    waypaper # backup wallpaper GUI
    xwayland-satellite # Xwayland outside your Wayland compositor
    nwg-displays # Manage Displays
    nwg-drawer # drawer GUI
    nwg-look # Look GUI
    rofi-emoji # rofi-emoji-wayland merged into rofi-emoji
    pear-desktop
    helium-browser
    zed-editor # Code editor with AI features
    popsicle
    gtk3
    gtk4
    localsend
    (pkgs.bottles.override { removeWarningPopup = true; })
    (pkgs.tetrio-desktop.override { withTetrioPlus = false; })
    evince
    prismlauncher
    webkitgtk_4_1
  ];
}
