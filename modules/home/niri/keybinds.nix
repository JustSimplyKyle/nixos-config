{
  host,
  terminal,
  browser,
  barChoice,
  hostKeybinds ? "",
  config,
  ...
}:
let
  dmsPath = "${config.home.homeDirectory}/.local/bin/dms";

   # Determine launcher command based on barChoice
   launcherCommand =
    if barChoice == "noctalia" then
      ''"noctalia-shell" "ipc" "call" "launcher" "toggle"''
    else if barChoice == "dms" then
      ''"${dmsPath}" "ipc" "call" "spotlight" "toggle"''
    # waybar or default
    else
      ''"rofi" "-show" "drun"'';

# Noctalia-specific keybinds
noctaliaKeybinds =
    if barChoice == "noctalia" then
    ''
        // === Noctalia Controls ===
        Mod+Comma {
            spawn "noctalia-shell" "ipc" "call" "settings" "toggle";
        }
        Mod+Alt+S {
            spawn "noctalia-shell" "ipc" "call" "settings" "toggle";
        }
        Mod+Shift+C {
            spawn "noctalia-shell" "ipc" "call" "controlCenter" "toggle";
        }
        XF86AudioRaiseVolume { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; } 
        XF86AudioLowerVolume { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; } 
        XF86AudioMute { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }  
        XF86MonBrightnessDown { spawn-sh "brightnessctl set 5%-"; } 
        XF86MonBrightnessUp { spawn-sh "brightnessctl set +5%"; } 
      ''
    else
    "";

# DMS-specific keybinds
dmsKeybinds =
if barChoice == "dms" then
''
        // === DMS Controls ===
        Mod+Comma { spawn "ignis" "open-window" "Settings"; }
        Mod+Shift+V {
            spawn "${dmsPath}" "ipc" "call" "clipboard" "toggle";
        }
        Mod+M {
            spawn "${dmsPath}" "ipc" "call" "processlist" "toggle";
        }
        Mod+Alt+S {
            spawn "${dmsPath}" "ipc" "call" "settings" "toggle";
        }
        Mod+N { spawn "${dmsPath}" "ipc" "call" "notifications" "toggle"; }
        Mod+Shift+N { spawn "${dmsPath}" "ipc" "call" "notepad" "toggle"; }

        // === Security ===
        Mod+Alt+L {
            spawn "${dmsPath}" "ipc" "call" "lock" "lock";
        }
        Ctrl+Alt+Delete {
            spawn "${dmsPath}" "ipc" "call" "processlist" "toggle";
        }

        // === Audio Controls ===
        XF86AudioRaiseVolume allow-when-locked=true {
            spawn "${dmsPath}" "ipc" "call" "audio" "increment" "3";
        }
        XF86AudioLowerVolume allow-when-locked=true {
            spawn "${dmsPath}" "ipc" "call" "audio" "decrement" "3";
        }
        XF86AudioMute allow-when-locked=true {
            spawn "${dmsPath}" "ipc" "call" "audio" "mute";
        }
        XF86AudioMicMute allow-when-locked=true {
            spawn "${dmsPath}" "ipc" "call" "audio" "micmute";
        }

        // === Monitor Brightness Controls ===
        XF86MonBrightnessUp allow-when-locked=true {
           spawn "${dmsPath}" "ipc" "call" "brightness" "increment" "5" "";
        }
        XF86MonBrightnessDown allow-when-locked=true {
           spawn "${dmsPath}" "ipc" "call" "brightness" "decrement" "5" "";
        }
      ''
    else
    "";
in
''
  binds {
      // === System & Overview ===
      Mod+X repeat=false { toggle-overview; }
      Mod+O repeat=false { toggle-overview; }
      Mod+Shift+Slash { show-hotkey-overlay; }

      // === Application Launchers ===
      Mod+Return { spawn "${terminal}"; }
      Mod+D { spawn ${launcherCommand}; }

      ${noctaliaKeybinds}
      ${dmsKeybinds}

      // === Security ===
      Super+Alt+L { spawn "hyprlock"; }
      Mod+Shift+E { quit; }

      // === Keyboard Brightness Controls ===
      XF86KbdBrightnessUp allow-when-locked=true {
          spawn "kbdbrite.sh" "up";
      }
      XF86KbdBrightnessDown allow-when-locked=true {
          spawn "kbdbrite.sh" "down";
      }

      // === Window Management ===
      Mod+Shift+Q repeat=false { close-window; }
      Mod+Alt+F { maximize-column; }
      Mod+F { fullscreen-window; }
      Mod+V { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
      Mod+Tab { toggle-column-tabbed-display; }

      // === Focus Navigation ===
      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+J     { focus-window-or-workspace-down; }
      Mod+K     { focus-window-or-workspace-up; }
      Mod+L     { focus-column-right; }

      // === Window Movement ===
      Mod+Shift+H     { move-column-left-or-to-monitor-left; }
      Mod+Shift+J     { move-window-down-or-to-workspace-down; }
      Mod+Shift+K     { move-window-up-or-to-workspace-up; }
      Mod+Shift+L     { move-column-right-or-to-monitor-right; }

      // === Column Navigation ===
      Mod+Home { focus-column-first; }
      Mod+End  { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End  { move-column-to-last; }

      // === Monitor Navigation ===
      Mod+Ctrl+Left  { focus-monitor-left; }
      Mod+Ctrl+Right { focus-monitor-right; }
      Mod+Ctrl+H     { focus-monitor-left; }
      Mod+Ctrl+J     { focus-monitor-down; }
      Mod+Ctrl+K     { focus-monitor-up; }
      Mod+Ctrl+L     { focus-monitor-right; }

      // === Move to Monitor ===
      Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
      Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
      Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
      Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
      Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

      // === Workspace Navigation ===
      Mod+U                { focus-workspace-down; }
      Mod+I                { focus-workspace-up; }
      Mod+Ctrl+Down        { focus-workspace-down; }
      Mod+Ctrl+Up          { focus-workspace-up; }
      Mod+Ctrl+Alt+Down    { move-column-to-workspace-down; }
      Mod+Ctrl+Alt+Up      { move-column-to-workspace-up; }

      // === Move Workspaces ===
      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up   { move-workspace-up; }
      Mod+Shift+U         { move-workspace-down; }
      Mod+Shift+I         { move-workspace-up; }

      // === Mouse Wheel Navigation ===
      Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

      Mod+WheelScrollRight      { focus-column-right; }
      Mod+WheelScrollLeft       { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft  { move-column-left; }

      Mod+Shift+WheelScrollDown      { focus-column-right; }
      Mod+Shift+WheelScrollUp        { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

      // === Numbered Workspaces ===
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      // === Move to Numbered Workspaces ===
      Alt+1 { move-column-to-workspace 1; }
      Alt+2 { move-column-to-workspace 2; }
      Alt+3 { move-column-to-workspace 3; }
      Alt+4 { move-column-to-workspace 4; }
      Alt+5 { move-column-to-workspace 5; }
      Alt+6 { move-column-to-workspace 6; }
      Alt+7 { move-column-to-workspace 7; }
      Alt+8 { move-column-to-workspace 8; }
      Alt+9 { move-column-to-workspace 9; }

      // === Column Management ===
      Mod+BracketLeft  { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+Period { expel-window-from-column; }

      // === Sizing & Layout ===
      Mod+R { switch-preset-column-width; }
      Mod+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R { reset-window-height; }
      Mod+Ctrl+F { expand-column-to-available-width; }
      Mod+Ctrl+C { center-column; }

      // === Manual Sizing ===
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      // === Screenshots ===
      Mod+Shift+S { screenshot; }
      XF86Launch1 { screenshot; }
      Ctrl+XF86Launch1 { screenshot-screen; }
      Alt+XF86Launch1 { screenshot-window; }
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      // === Ignis Screen Recording ===
      Mod+Alt+Shift+R { spawn "ignis" "run-command" "recorder-record-screen"; }
      Mod+Alt+Shift+S { spawn "ignis" "run-command" "recorder-record-region"; }
      Mod+Alt+Shift+W { spawn "ignis" "run-command" "recorder-record-portal"; }

      // === Noctalia Config Sync ===
      Ctrl+Shift+S {
          spawn "sh" "-c" "/home/don/black-don-os/modules/home/noctalia-shell/sync-from-gui.py && notify-send 'Noctalia Config' 'Settings synced to Nix template' -i preferences-system";
      }

      // === System Controls ===
      Mod+Escape { spawn "ignis" "open-window" "PowerMenu"; }
      Mod+Alt+P { power-off-monitors; }

      // === Custom Application Launchers ===
      Mod+C { spawn "${browser}"; }
      Mod+W { spawn "vesktop"; }
      Mod+S { spawn "steam"; }
      Mod+Shift+O { spawn "obs"; }
      Mod+Z { spawn "zed-fix"; }

      // === Dynamic Cast ===
      Mod+P { set-dynamic-cast-monitor; }
      Mod+Shift+P { set-dynamic-cast-window; }
      Mod+Ctrl+P { clear-dynamic-cast-target; }

      ${hostKeybinds}
  }
''
