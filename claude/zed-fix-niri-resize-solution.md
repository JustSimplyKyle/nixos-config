# Zed Fix Script for Niri - Window Resize Solution

**Date:** 2025-10-26  
**Last Updated:** 2025-10-26  
**Issue:** Zed Editor unresponsive on first launch in niri window manager  
**Solution:** Automatic window resize trigger after launch using preset width cycling

## Problem Description

When launching Zed Editor in niri, the application is unresponsive until the window is manually moved or resized. This is a known issue with Zed on niri.

## Solution Implemented

Updated `/home/don/black-don-os/modules/home/scripts/zed-fix.nix` to automatically resize the window after launch, triggering responsiveness.

### Script Behavior

1. **Launch Zed in background** - Starts `zeditor` as a background process
2. **Wait for window** - Polls for up to 5 seconds for Zed window to appear
3. **Get window ID** - Uses `niri msg windows --json` and `jq` to extract window ID
4. **Trigger resize** - Cycles preset window width forward then back (simulates mod++ then mod+-)
5. **Wait for process** - Keeps script running to prevent process orphaning

### Iteration History

**v1 (Initial):** Used `set-window-width` with "+1" and "-1" values  
**Issue:** Window opened but did not resize, remained unresponsive  
**Fix:** Manual mod++ then mod+- made it responsive  

**v2 (Current):** Uses `switch-preset-window-width` and `switch-preset-window-width-back`  
**Reason:** Mimics the manual keybind actions that successfully triggered responsiveness

### Key Commands Used

```bash
# Query windows in JSON format
niri msg windows --json

# Filter for Zed window using jq
jq '.[] | select(.app_id == "dev.zed.Zed")'

# Resize window by cycling preset widths (current method)
niri msg action switch-preset-window-width --id <WINDOW_ID>
niri msg action switch-preset-window-width-back --id <WINDOW_ID>
```

## Script Code

```nix
{ pkgs }:

pkgs.writeShellScriptBin "zed-fix" ''
  # Launch Zed editor in the background
  zeditor &
  ZED_PID=$!
  
  # Wait for the Zed window to appear (max 5 seconds)
  for i in {1..50}; do
    if niri msg windows --json | ${pkgs.jq}/bin/jq -e '.[] | select(.app_id == "dev.zed.Zed")' > /dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
  
  # Small additional delay to ensure window is ready
  sleep 0.2
  
  # Get the Zed window ID
  ZED_WINDOW_ID=$(niri msg windows --json | ${pkgs.jq}/bin/jq -r '.[] | select(.app_id == "dev.zed.Zed") | .id' | head -n1)
  
  if [ -n "$ZED_WINDOW_ID" ]; then
    # Resize the window to trigger responsiveness
    # Use preset width switching (simulates mod++ / mod+-)
    niri msg action switch-preset-window-width --id "$ZED_WINDOW_ID"
    sleep 0.1
    # Switch back to restore original size
    niri msg action switch-preset-window-width-back --id "$ZED_WINDOW_ID"
  fi
  
  # Wait for the Zed process (optional - keeps script running)
  wait $ZED_PID
''
```

## Usage

After rebuilding the configuration:

```bash
dcli rebuild
```

Launch Zed using the fix script:

```bash
zed-fix
```

## Technical Details

- **Window detection:** Uses `dev.zed.Zed` as the app_id for filtering
- **Timing:** 50 iterations × 0.1s = 5 second max wait time
- **Resize method:** Cycles through preset window widths (forward then back)
- **Dependencies:** Requires `jq` package for JSON parsing (included via `${pkgs.jq}`)
- **Why preset switching?** The `set-window-width` command with relative values (+1/-1) did not trigger responsiveness, but preset width cycling (matching mod++/mod+- keybinds) does

## File Location

`/home/don/black-don-os/modules/home/scripts/zed-fix.nix`

## Related Files

- `/home/don/black-don-os/modules/home/scripts/default.nix` - Script imports
- `/home/don/black-don-os/modules/home/niri/layout.nix` - Niri layout configuration

## Niri Resources

- `niri msg --help` - List all available commands
- `niri msg action --help` - List all window actions
- `niri msg windows --json` - Get window information in JSON format
