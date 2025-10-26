{
  host,
  stylixImage,
  startupApps,
  barChoice,
  ...
}:
let
  # Determine which bar to launch - returns the full spawn command
  barStartupCommand =
    if barChoice == "dms" then
      ''spawn-at-startup "dms-start"''
    else if barChoice == "noctalia" then
      ''spawn-at-startup "noctalia-shell"''
    else
      ''spawn-at-startup "waybar"'';
in
''
  spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"
  spawn-at-startup "swww-daemon"
  spawn-at-startup "swww" "img" "${stylixImage}"
  spawn-at-startup "wal" "-R"
  ${barStartupCommand}
  spawn-at-startup "/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"
  spawn-at-startup "/usr/lib/xdg-desktop-portal-gtk"
  spawn-at-startup "/usr/lib/xdg-desktop-portal-gnome"
  spawn-at-startup "vesktop"
  spawn-at-startup "Telegram"
''
