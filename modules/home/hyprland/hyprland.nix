{
  host,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit
    (import ../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    keyboardLayout
    stylixImage
    startupApps
    hyprexpoSettings
    hyprscrollingSettings
    ;
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  # Legacy support
  enableDMSLegacy = variables.enableDankMaterialShell or false;
  actualBarChoice = if variables ? barChoice then barChoice else (if enableDMSLegacy then "dms" else "waybar");
in {
  home.packages = with pkgs; [
    swww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils # needed for banners and ANR messages
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  systemd.user.services.ydotool = {
    Unit = {
      Description = "ydotool daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      Restart = "always";
    };
    Install.WantedBy = ["hyprland-session.target"];
  };
  # Place Files Inside Home Directory
  home.file = {
    "Pictures/Wallpapers" = {
      source = ../../../wallpapers;
      recursive = true;
    };
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
      inputs.hyprland-plugins.packages.${pkgs.system}.hyprscrolling
    ];
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = ["--all"];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      # Plugin configuration
      plugin = {
        hyprexpo = hyprexpoSettings;
        hyprscrolling = hyprscrollingSettings;
      };

      exec-once = [
        "wl-paste --type text --watch cliphist store # Stores only text data"
        "wl-paste --type image --watch cliphist store # Stores only image data"
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "killall -q swww;sleep .5 && swww init"
      ] ++ (
        if actualBarChoice == "dms" then [
          # Launch Dank Material Shell via quickshell
          "killall -q quickshell;sleep .5 && quickshell -c DankMaterialShell"
        ] else if actualBarChoice == "noctalia" then [
          # Launch Noctalia Shell
          "killall -q noctalia-shell;sleep .5 && noctalia-shell"
        ] else [
          # Launch waybar (default)
          "killall -q waybar;sleep .5 && waybar"
        ]
      ) ++ [
        "killall -q swaync;sleep .5 && swaync"
        "nm-applet --indicator"
        "pypr &"
        "sleep 1.5 && swww img ${stylixImage}"
      ] ++ startupApps;

      input = {
        kb_layout = "${keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        numlock_by_default = true;
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
      };

      general = {
        "$modifier" = "SUPER";
        layout = "scrolling";
        gaps_in = 5;
        gaps_out = 7;
        border_size = 3;
        resize_on_border = true;
        "col.active_border" = "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vfr = true; # Variable Frame Rate
        vrr = 2; #Variable Refresh Rate  Might need to set to 0 for NVIDIA/AQ_DRM_DEVICES
        # Screen flashing to black momentarily or going black when app is fullscreen
        # Try setting vrr to 0

        #  Application not responding (ANR) settings
        enable_anr_dialog = true;
        anr_missed_pings = 20;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      decoration = {
        rounding = 2;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = false;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      # Ensure Xwayland windows render at integer scale; compositor scales them
      xwayland = {
        force_zero_scaling = true;
      };
    };

    extraConfig = ''
      monitor=,preferred,auto,auto
      monitor=Virtual-1,1920x1080@60,auto,1
      ${extraMonitorSettings}
      # Enable blur on bar
      ${if actualBarChoice == "dms" then "layerrule = blur,quickshell"
        else if actualBarChoice == "noctalia" then "layerrule = blur,noctalia"
        else "layerrule = blur,waybar"}
    '';
  };
}
