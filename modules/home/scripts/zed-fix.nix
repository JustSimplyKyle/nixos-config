{ pkgs }:

pkgs.writeShellScriptBin "zed-fix" ''
  # Launch Zed and trigger a layout recalculation to fix input handling

  zeditor &
  ZED_PID=$!

  # Wait for Zed window to appear and be mapped
  sleep 1.5

  # Get the window ID of the newly launched Zed window
  WINDOW_ID=$(niri msg windows -j | ${pkgs.jq}/bin/jq -r ".[] | select(.app_id == \"dev.zed.Zed\") | .id" | head -1)

  if [ -n "$WINDOW_ID" ]; then
    # Focus the Zed window
    niri msg action focus-window --id "$WINDOW_ID"
    sleep 0.2

    # Resize the window using set-window-width and set-window-height
    # This directly manipulates the window size rather than the column
    niri msg action set-window-width --id "$WINDOW_ID" -- "-10"
    sleep 0.1
    niri msg action set-window-height --id "$WINDOW_ID" -- "-10"
    sleep 0.1
    niri msg action set-window-width --id "$WINDOW_ID" -- "+10"
    sleep 0.1
    niri msg action set-window-height --id "$WINDOW_ID" -- "+10"
  else
    echo "Warning: Could not find Zed window to resize"
  fi
''
