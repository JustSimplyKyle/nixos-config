{
  host,
  stylixImage,
  startupApps,
  barChoice,
  ...
}:
let
  # Determine which bar to launch
  # Note: waybar is handled by systemd service, not spawn-at-startup
  barStartupCommand =
    if barChoice == "dms" then
      ''spawn-at-startup "${builtins.getEnv "HOME"}/.local/bin/dms" "run"''
    else if barChoice == "noctalia" then
      ''spawn-at-startup "noctalia-shell"''
    else
      ''// waybar started via systemd service'';
in
''
  spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
  ${barStartupCommand}
  spawn-at-startup "bash" "-c" "swww-daemon && sleep 1 && swww img '${stylixImage}'"
  spawn-at-startup "wal" "-R"
  spawn-at-startup "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
  spawn-at-startup "vesktop"
  spawn-at-startup "Telegram"
''
