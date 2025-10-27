# OBS Flatpak Screen Sharing Fix

**Date:** 2025-10-26 21:58  
**Host:** nixos-leno  
**Issue:** OBS flatpak cannot screen share in Niri

## Problem

OBS flatpak was missing explicit D-Bus permissions to access the XDG Desktop Portal, even though the portal services were running correctly. Additionally, the portal configuration file wasn't being created in the user's home directory.

## Root Cause

1. Flatpak sandbox was blocking OBS from accessing portal D-Bus interfaces
2. Missing `~/.config/xdg-desktop-portal/portals.conf` file
3. Portal services needed to be aware of the configuration

## Solution Applied

### 1. Grant OBS Flatpak Portal Permissions

```bash
# Grant portal desktop and screencast access
flatpak override --user com.obsproject.Studio --talk-name=org.freedesktop.portal.Desktop --talk-name=org.freedesktop.portal.ScreenCast

# Ensure pipewire socket access
flatpak override --user com.obsproject.Studio --filesystem=xdg-run/pipewire-0:ro
```

### 2. Create Portal Configuration File

Created `~/.config/xdg-desktop-portal/portals.conf`:

```ini
[preferred]
default=gnome;gtk
org.freedesktop.impl.portal.ScreenCast=gnome
org.freedesktop.impl.portal.Screenshot=gnome
```

This explicitly tells the portal system to use GNOME portal for screen sharing.

## Files Modified

- `~/.var/app/com.obsproject.Studio/.flatpak-info` - Updated via flatpak override (automatic)
- `~/.config/xdg-desktop-portal/portals.conf` - Created new file

## Applied Overrides

Verified with `flatpak override --user --show com.obsproject.Studio`:

```
[Context]
filesystems=xdg-run/pipewire-0:ro;

[Session Bus Policy]
org.freedesktop.portal.Desktop=talk
org.freedesktop.portal.ScreenCast=talk
```

## Steps to Test After Logout/Login

1. **Log out and back in** (required for changes to take full effect)
2. **Launch OBS** from your application menu
3. **Add a source**: 
   - Click the "+" under Sources
   - Choose "Screen Capture (PipeWire)" or "Window Capture (PipeWire)"
4. **You should see**: GNOME screen picker dialog
5. **Select**: Your screen or window to share
6. **Screen sharing should work!**

## Diagnostic Commands (If Still Not Working)

```bash
# Check portal services are running
systemctl --user status xdg-desktop-portal-gnome
systemctl --user status xdg-desktop-portal

# Verify OBS can see the portal
flatpak run --command=busctl com.obsproject.Studio --user list | grep portal

# Check for errors in journal
journalctl --user -u xdg-desktop-portal-gnome -n 50

# Verify portal configuration
cat ~/.config/xdg-desktop-portal/portals.conf

# Check flatpak overrides
flatpak override --user --show com.obsproject.Studio

# List running portal D-Bus services
busctl --user list | grep portal
```

## Expected Portal Services

When working correctly, you should see:

```
org.freedesktop.impl.portal.desktop.gnome      [running]
org.freedesktop.impl.portal.desktop.gtk        [running]
org.freedesktop.portal.Desktop                 [running]
org.freedesktop.portal.Documents               [running]
```

## Why Logout is Required

1. **Portal configuration reload** - The `portals.conf` file is read at session start
2. **D-Bus session refresh** - New flatpak permissions need fresh D-Bus session
3. **Systemd user services** - Portal services need to restart with new configuration

## Related Files

- `/home/don/black-don-os/modules/core/flatpak.nix` - System-wide portal configuration
- `/home/don/black-don-os/modules/home/niri/niri.nix` - Niri portal systemd services
- `~/.config/xdg-desktop-portal/portals.conf` - User portal preferences (newly created)

## Notes

- The system-wide portal configuration in `modules/core/flatpak.nix` was already correct
- The portal systemd services in `modules/home/niri/niri.nix` were already configured properly
- The missing piece was the **user-level portal config** and **flatpak-specific permissions**
- This is a common issue with flatpak applications on Wayland - they need explicit portal access

## Comparison with Previous Fix

The previous fix (documented in `20251026-211904-niri-xdg-portal-gnome-setup.md`) solved:
- System-wide portal configuration
- Systemd service setup
- PipeWire dependency ordering

This fix solves:
- **Flatpak-specific** portal access permissions
- User-level portal configuration file
- OBS sandbox permissions

Both fixes are complementary and necessary for full screen sharing support.
