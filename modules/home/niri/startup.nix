{
  host,
  stylixImage,
  startupApps,
  barChoice,
  ...
}:
let
  # Determine which bar to launch
  barStartupCommand =
    if barChoice == "dms" then
      # ''spawn-at-startup "${builtins.getEnv "HOME"}/.local/bin/dms" "run"''
      ''spawn-at-startup "dms" "run"''
    else if barChoice == "noctalia" then
      ''spawn-at-startup "noctalia-shell"''
    else
      ''spawn-at-startup "waybar"'';
in
''
  spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
  ${barStartupCommand}
  spawn-at-startup "swww-daemon"
  spawn-at-startup "swww" "img" "${stylixImage}"
  spawn-at-startup "wal" "-R"
  spawn-at-startup "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
  spawn-at-startup "vesktop"
  spawn-at-startup "Telegram"
''
