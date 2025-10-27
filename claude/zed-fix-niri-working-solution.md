# Zed Fix Script for Niri - Working Solution

**Date:** 2025-10-26  
**Status:** ✅ WORKING  
**Issue:** Zed Editor unresponsive on first launch in niri window manager  
**Solution:** Column width adjustment using percentage-based resize

## Problem Description

When launching Zed Editor in niri, the application is unresponsive until the window is manually moved or resized. This is a known issue with Zed on niri that requires triggering a layout recalculation.

## Working Solution

The script uses `set-column-width` with percentage values to trigger a layout recalculation:

```bash
zeditor &
sleep 0.6

# Resize window slightly and back to force layout recalculation
niri msg action set-column-width "-1%"
sleep 0.3
niri msg action set-column-width "+1%"
```

### Why This Works

- **`set-column-width` with percentages**: Operates on the currently focused window
- **No window ID needed**: Simpler than querying for window IDs
- **Layout recalculation**: The `-1%` / `+1%` sequence forces niri to recalculate the layout
- **Proven timings**: 0.6s for initial launch, 0.3s between resize commands

## What Didn't Work

### Attempt 1: Window-specific resize with ID lookup
```bash
# This didn't work
ZED_WINDOW_ID=$(niri msg windows --json | jq -r '.[] | select(.app_id == "dev.zed.Zed") | .id')
niri msg action set-window-width "+1" --id "$ZED_WINDOW_ID"
niri msg action set-window-width "-1" --id "$ZED_WINDOW_ID"
```
**Issue:** Window opened but didn't resize, remained unresponsive

### Attempt 2: Preset width switching
```bash
# This didn't work
niri msg action switch-preset-window-width --id "$ZED_WINDOW_ID"
niri msg action switch-preset-window-width-back --id "$ZED_WINDOW_ID"
```
**Issue:** Didn't trigger the layout recalculation properly

### Attempt 3: Single resize without reversal
```bash
# This didn't work
niri msg action switch-preset-window-width --id "$ZED_WINDOW_ID"
```
**Issue:** Still didn't trigger responsiveness

## Current Implementation

File: `/home/don/black-don-os/modules/home/scripts/zed-fix.nix`

```nix
{ pkgs }:

pkgs.writeShellScriptBin "zed-fix" ''
  # Launch Zed and trigger a layout recalculation to fix input handling
  zeditor &
  sleep 0.6

  # Resize window slightly and back to force layout recalculation
  niri msg action set-column-width "-1%"
  sleep 0.3
  niri msg action set-column-width "+1%"
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

The Zed window will appear and automatically become responsive.

## Key Insights

1. **Percentage-based resize is crucial** - Absolute values or preset switching don't work
2. **Focused window assumption** - Script assumes Zed will be the focused window after launch
3. **Timing matters** - 0.6s initial wait ensures window is created before resize
4. **Bidirectional resize required** - Both `-1%` and `+1%` needed to trigger recalculation

## Origin

This solution was adapted from a working Arch Linux installation script, proving that the approach is reliable across different NixOS configurations.

## Related Files

- `/home/don/black-don-os/modules/home/scripts/zed-fix.nix` - Script implementation
- `/home/don/black-don-os/modules/home/scripts/default.nix` - Script imports
- `/home/don/black-don-os/modules/home/niri/layout.nix` - Niri layout configuration

## Niri Commands Reference

```bash
# Set column width with percentage
niri msg action set-column-width "-1%"
niri msg action set-column-width "+1%"

# Query windows
niri msg windows --json

# List all actions
niri msg action --help
```
