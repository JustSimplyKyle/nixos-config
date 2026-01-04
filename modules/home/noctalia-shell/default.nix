{
  config,
  lib,
  pkgs,
  inputs,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  enableNoctalia = barChoice == "noctalia";
in
{
  imports = lib.optionals enableNoctalia [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf enableNoctalia {
    programs.waybar.enable = lib.mkForce false;
    home.packages = [ inputs.noctalia.packages.${pkgs.system}.default ];

    home.file.".config/noctalia/settings.json.template" = {
      text = builtins.toJSON {
        appLauncher = {
          customLaunchPrefix = "";
          customLaunchPrefixEnabled = false;
          enableClipPreview = true;
          enableClipboardHistory = false;
          iconMode = "tabler";
          ignoreMouseInput = false;
          pinnedExecs = [ ];
          position = "center";
          showCategories = true;
          sortByMostUsed = true;
          terminalCommand = "xterm -e";
          useApp2Unit = false;
          viewMode = "list";
        };
        audio = {
          cavaFrameRate = 165;
          externalMixer = "pwvucontrol || pavucontrol";
          mprisBlacklist = [ ];
          preferredPlayer = "mpv";
          visualizerType = "linear";
          volumeOverdrive = false;
          volumeStep = 5;
        };
        bar = {
          backgroundOpacity = 1;
          capsuleOpacity = 1;
          density = "spacious";
          exclusive = true;
          floating = true;
          marginHorizontal = 0.25;
          marginVertical = 0.25;
          monitors = [ ];
          outerCorners = true;
          position = "top";
          showCapsule = true;
          showOutline = false;
          useSeparateOpacity = false;
          widgets = {
            center = [
              {
                customFont = "";
                formatHorizontal = "h:mm AP, MMM dd";
                formatVertical = "HH mm - dd MM";
                id = "Clock";
                tooltipFormat = "HH:mm ddd, MMM dd";
                useCustomFont = false;
                usePrimaryColor = true;
              }
            ];
            left = [
              {
                characterCount = 2;
                colorizeIcons = false;
                enableScrollWheel = true;
                followFocusedScreen = false;
                groupedBorderOpacity = 1;
                hideUnoccupied = false;
                iconScale = 0.8;
                id = "Workspace";
                labelMode = "index";
                showApplications = false;
                showLabelsOnlyWhenOccupied = true;
                unfocusedIconsOpacity = 1;
              }
              {
                colorizeIcons = false;
                hideMode = "hidden";
                id = "ActiveWindow";
                maxWidth = 300;
                scrollingMode = "hover";
                showIcon = true;
                useFixedWidth = false;
              }
              {
                hideMode = "hidden";
                hideWhenIdle = false;
                id = "MediaMini";
                maxWidth = 250;
                scrollingMode = "always";
                showAlbumArt = true;
                showArtistFirst = true;
                showProgressRing = true;
                showVisualizer = false;
                useFixedWidth = false;
                visualizerType = "linear";
              }
            ];
            right = [
              {
                blacklist = [ ];
                colorizeIcons = false;
                drawerEnabled = true;
                hidePassive = false;
                id = "Tray";
                pinned = [ ];
              }
              {
                compactMode = true;
                diskPath = "/";
                id = "SystemMonitor";
                showCpuTemp = true;
                showCpuUsage = true;
                showDiskUsage = false;
                showGpuTemp = false;
                showLoadAverage = false;
                showMemoryAsPercent = false;
                showMemoryUsage = true;
                showNetworkStats = false;
                useMonospaceFont = true;
                usePrimaryColor = false;
              }
              {
                hideWhenZero = true;
                id = "NotificationHistory";
                showUnreadBadge = true;
              }
              {
                displayMode = "onhover";
                id = "Volume";
              }
              {
                colorizeDistroLogo = false;
                colorizeSystemIcon = "none";
                customIconPath = "/home/don/black-don-os/modules/home/fastfetch/blackdontrans.png";
                enableColorization = false;
                icon = "noctalia";
                id = "ControlCenter";
                useDistroLogo = false;
              }
            ];
          };
        };
        brightness = {
          brightnessStep = 5;
          enableDdcSupport = false;
          enforceMinimum = true;
        };
        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = true;
              id = "timer-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
          ];
        };
        colorSchemes = {
          darkMode = true;
          generateTemplatesForPredefined = true;
          manualSunrise = "06:30";
          manualSunset = "18:30";
          matugenSchemeType = "scheme-fruit-salad";
          predefinedScheme = "Rose Pine";
          schedulingMode = "off";
          useWallpaperColors = false;
        };
        controlCenter = {
          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = true;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
            {
              enabled = false;
              id = "brightness-card";
            }
          ];
          diskPath = "/";
          position = "center";
          shortcuts = {
            left = [
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "ScreenRecorder";
              }
              {
                id = "WallpaperSelector";
              }
            ];
            right = [
              {
                id = "Notifications";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "KeepAwake";
              }
              {
                id = "NightLight";
              }
            ];
          };
        };
        desktopWidgets = {
          enabled = false;
          gridSnap = false;
          monitorWidgets = [ ];
        };
        dock = {
          animationSpeed = 1;
          backgroundOpacity = 1;
          colorizeIcons = true;
          deadOpacity = 0.6;
          displayMode = "exclusive";
          enabled = true;
          floatingRatio = 1;
          inactiveIndicators = false;
          monitors = [ "DP-1" ];
          onlySameOutput = true;
          pinnedApps = [ ];
          pinnedStatic = false;
          size = 1;
        };
        general = {
          allowPanelsOnScreenWithoutBar = true;
          animationDisabled = false;
          animationSpeed = 1;
          avatarImage = "/home/don/black-don-os/modules/home/fastfetch/blackdontrans.png";
          boxRadiusRatio = 1;
          compactLockScreen = false;
          dimmerOpacity = 0.2;
          enableShadows = true;
          forceBlackScreenCorners = false;
          iRadiusRatio = 1;
          language = "en";
          lockOnSuspend = true;
          radiusRatio = 0.5;
          scaleRatio = 1.2;
          screenRadiusRatio = 1;
          shadowDirection = "bottom_right";
          shadowOffsetX = 2;
          shadowOffsetY = 3;
          showHibernateOnLockScreen = true;
          showScreenCorners = false;
          showSessionButtonsOnLockScreen = true;
        };
        hooks = {
          darkModeChange = "";
          enabled = false;
          performanceModeDisabled = "";
          performanceModeEnabled = "";
          screenLock = "";
          screenUnlock = "";
          wallpaperChange = "";
        };
        "location" = {
          analogClockInCalendar = false;
          firstDayOfWeek = -1;
          name = "Taoyuan, Taiwan";
          showCalendarEvents = true;
          showCalendarWeather = true;
          showWeekNumberInCalendar = false;
          use12hourFormat = false;
          useFahrenheit = false;
          weatherEnabled = true;
          weatherShowEffects = true;
        };
        network = {
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          bluetoothRssiPollIntervalMs = 10000;
          bluetoothRssiPollingEnabled = false;
          wifiDetailsViewMode = "grid";
          wifiEnabled = true;
        };
        nightLight = {
          autoSchedule = true;
          dayTemp = "6500";
          enabled = false;
          forced = false;
          manualSunrise = "06:30";
          manualSunset = "18:30";
          nightTemp = "4000";
        };
        notifications = {
          backgroundOpacity = 1;
          criticalUrgencyDuration = 15;
          enableKeyboardLayoutToast = true;
          enabled = true;
          "location" = "top_right";
          lowUrgencyDuration = 3;
          monitors = [ ];
          normalUrgencyDuration = 8;
          overlayLayer = true;
          respectExpireTimeout = false;
          saveToHistory = {
            critical = true;
            low = true;
            normal = true;
          };
          sounds = {
            criticalSoundFile = "";
            enabled = false;
            excludedApps = "discord,firefox,chrome,chromium,edge";
            lowSoundFile = "";
            normalSoundFile = "";
            separateSounds = false;
            volume = 0.5;
          };
        };
        osd = {
          autoHideMs = 2000;
          backgroundOpacity = 1;
          enabled = true;
          enabledTypes = [ 0 1 2 4 ];
          "location" = "top_right";
          monitors = [ ];
          overlayLayer = true;
        };
        screenRecorder = {
          audioCodec = "opus";
          audioSource = "default_output";
          colorRange = "limited";
          copyToClipboard = false;
          directory = "";
          frameRate = 60;
          quality = "very_high";
          showCursor = true;
          videoCodec = "vp9";
          videoSource = "portal";
        };
        sessionMenu = {
          countdownDuration = 10000;
          enableCountdown = true;
          largeButtonsLayout = "grid";
          largeButtonsStyle = false;
          position = "center";
          powerOptions = [
            {
              action = "lock";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
            {
              action = "suspend";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
            {
              action = "hibernate";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
            {
              action = "reboot";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
            {
              action = "logout";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
            {
              action = "shutdown";
              command = "";
              countdownEnabled = true;
              enabled = true;
            }
          ];
          showHeader = true;
          showNumberLabels = true;
        };
        settingsVersion = 37;
        systemMonitor = {
          cpuCriticalThreshold = 90;
          cpuPollingInterval = 3000;
          cpuWarningThreshold = 80;
          criticalColor = "";
          diskCriticalThreshold = 90;
          diskPollingInterval = 3000;
          diskWarningThreshold = 80;
          enableDgpuMonitoring = false;
          externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
          gpuCriticalThreshold = 90;
          gpuPollingInterval = 3000;
          gpuWarningThreshold = 80;
          loadAvgPollingInterval = 3000;
          memCriticalThreshold = 90;
          memPollingInterval = 3000;
          memWarningThreshold = 80;
          networkPollingInterval = 3000;
          tempCriticalThreshold = 90;
          tempPollingInterval = 3000;
          tempWarningThreshold = 80;
          useCustomColors = false;
          warningColor = "";
        };
        templates = {
          alacritty = false;
          cava = false;
          code = false;
          discord = true;
          emacs = false;
          enableUserTemplates = false;
          foot = false;
          fuzzel = false;
          ghostty = false;
          gtk = false;
          helix = false;
          hyprland = false;
          kcolorscheme = false;
          kitty = false;
          mango = false;
          niri = false;
          pywalfox = false;
          qt = false;
          spicetify = false;
          telegram = false;
          vicinae = false;
          walker = false;
          wezterm = false;
          yazi = false;
          zed = false;
        };
        ui = {
          boxBorderEnabled = false;
          fontDefault = "FiraCode Nerd Font";
          fontDefaultScale = 1;
          fontFixed = "DejaVu Sans Mono";
          fontFixedScale = 1;
          panelBackgroundOpacity = 0.93;
          panelsAttachedToBar = true;
          settingsPanelMode = "attached";
          tooltipsEnabled = true;
        };
        wallpaper = {
          directory = "/home/kyle/black-don-os/wallpapers";
          enableMultiMonitorDirectories = false;
          enabled = true;
          fillColor = "#000000";
          fillMode = "crop";
          hideWallpaperFilenames = false;
          monitorDirectories = [ ];
          overviewEnabled = true;
          panelPosition = "follow_bar";
          randomEnabled = true;
          randomIntervalSec = 300;
          recursiveSearch = false;
          setWallpaperOnAllMonitors = true;
          solidColor = "#1a1a2e";
          transitionDuration = 5000;
          transitionEdgeSmoothness = 0.05;
          transitionType = "disc";
          useSolidColor = false;
          useWallhaven = false;
          wallhavenApiKey = "";
          wallhavenCategories = "111";
          wallhavenOrder = "desc";
          wallhavenPurity = "100";
          wallhavenQuery = "";
          wallhavenRatios = "";
          wallhavenResolutionHeight = "";
          wallhavenResolutionMode = "atleast";
          wallhavenResolutionWidth = "";
          wallhavenSorting = "relevance";
          wallpaperChangeMode = "random";
        };
      };
    };

    home.activation.noctaliaSettingsInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      SETTINGS_FILE="$HOME/.config/noctalia/settings.json"
      TEMPLATE_FILE="$HOME/.config/noctalia/settings.json.template"

      if [ ! -f "$SETTINGS_FILE" ] || [ -L "$SETTINGS_FILE" ]; then
        $DRY_RUN_CMD rm -f "$SETTINGS_FILE"
        $DRY_RUN_CMD cp "$TEMPLATE_FILE" "$SETTINGS_FILE"
        $DRY_RUN_CMD chmod 644 "$SETTINGS_FILE"
      fi
    '';

    home.activation.noctaliaWarning = lib.hm.dag.entryAfter [ "noctaliaSettingsInit" ] ''
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo "🌙 Noctalia Shell is ENABLED"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "⚠️  Waybar has been automatically disabled"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📝 Configuration: ~/.config/noctalia/settings.json (GUI-editable)"
      $DRY_RUN_CMD echo "🎨 Settings synced from GUI (use ./sync-from-gui.py to update)"
      $DRY_RUN_CMD echo "✏️  All GUI changes persist across reboots"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "💡 To update Nix template from GUI changes:"
      $DRY_RUN_CMD echo "   cd modules/home/noctalia-shell && ./sync-from-gui.py"
      $DRY_RUN_CMD echo ""
      $DRY_RUN_CMD echo "📚 Docs: https://docs.noctalia.dev"
      $DRY_RUN_CMD echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      $DRY_RUN_CMD echo ""
    '';
  };
}
