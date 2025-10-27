# Niri XDG Desktop Portal GNOME Setup

**Date:** 2025-10-26  
**Host:** nixos-leno  
**Issue:** Screen sharing not working in OBS and browsers under Niri

## Problem

The system was using xdg-desktop-portal-hyprland configuration while running Niri window manager, and portals were being manually launched with hardcoded paths in startup configuration. This prevented proper screen sharing functionality in OBS and web browsers.

## Solution

Configured xdg-desktop-portal-gnome properly for Niri with systemd user services.

## Changes Made

### 1. Updated Portal Configuration (`modules/core/flatpak.nix`)

**Before:**
```nix
{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    configPackages = [pkgs.hyprland];
  };
  # ... rest of config
}
```

**After:**
```nix
{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
      };
    };
    configPackages = [pkgs.hyprland];
  };
  # ... rest of config
}
```

### 2. Removed Manual Portal Launches (`modules/home/niri/startup.nix`)

**Removed these lines:**
```nix
spawn-at-startup "/usr/lib/xdg-desktop-portal-gtk"
spawn-at-startup "/usr/lib/xdg-desktop-portal-gnome"
```

These were using hardcoded paths that don't work with NixOS and were conflicting with proper systemd service management.

### 3. Added Systemd User Services (`modules/home/niri/niri.nix`)

**Initial implementation (had issues with black screen):**
```nix
# XDG Desktop Portal services
systemd.user.services.xdg-desktop-portal-gnome = {
  Unit = {
    Description = "Portal service (GNOME implementation)";
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
  };
  Service = {
    Type = "dbus";
    BusName = "org.freedesktop.impl.portal.desktop.gnome";
    ExecStart = "${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};

systemd.user.services.xdg-desktop-portal-gtk = {
  Unit = {
    Description = "Portal service (GTK/GNOME implementation)";
    After = [ "graphical-session.target" ];
    PartOf = [ "graphical-session.target" ];
  };
  Service = {
    Type = "dbus";
    BusName = "org.freedesktop.impl.portal.desktop.gtk";
    ExecStart = "${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};
```

### 4. Fixed Black Screen Issue (Second Iteration)

**Problem:** After reboot, the screen selector appeared but showed only a black screen when sharing.

**Root Cause:** Portal services weren't waiting for PipeWire to be ready, and the main xdg-desktop-portal service was missing.

**Final Working Configuration:**
```nix
# XDG Desktop Portal services - properly configured for screen sharing
systemd.user.services.xdg-desktop-portal = {
  Unit = {
    Description = "Portal service";
    After = [ "graphical-session.target" "pipewire.service" ];
    PartOf = [ "graphical-session.target" ];
  };
  Service = {
    Type = "dbus";
    BusName = "org.freedesktop.portal.Desktop";
    ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
    Restart = "on-failure";
    Environment = [
      "XDG_CURRENT_DESKTOP=niri"
      "WAYLAND_DISPLAY=wayland-1"
    ];
  };
  Install.WantedBy = [ "graphical-session.target" ];
};

systemd.user.services.xdg-desktop-portal-gnome = {
  Unit = {
    Description = "Portal service (GNOME implementation)";
    After = [ "graphical-session.target" "pipewire.service" "xdg-desktop-portal.service" ];
    PartOf = [ "graphical-session.target" ];
    Requires = [ "pipewire.service" ];
  };
  Service = {
    Type = "dbus";
    BusName = "org.freedesktop.impl.portal.desktop.gnome";
    ExecStart = "${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome";
    Restart = "on-failure";
    Environment = [
      "XDG_CURRENT_DESKTOP=niri"
    ];
  };
  Install.WantedBy = [ "graphical-session.target" ];
};

systemd.user.services.xdg-desktop-portal-gtk = {
  Unit = {
    Description = "Portal service (GTK/GNOME implementation)";
    After = [ "graphical-session.target" "xdg-desktop-portal.service" ];
    PartOf = [ "graphical-session.target" ];
  };
  Service = {
    Type = "dbus";
    BusName = "org.freedesktop.impl.portal.desktop.gtk";
    ExecStart = "${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};
```

**Key Fixes:**
1. **Added main portal service** - `xdg-desktop-portal` coordinates all portal backends
2. **PipeWire dependency** - Services now wait for `pipewire.service` with `After` and `Requires`
3. **Proper ordering** - Portal backends wait for main portal service first
4. **Environment variables** - Set `XDG_CURRENT_DESKTOP=niri` and `WAYLAND_DISPLAY=wayland-1`

## Files Modified

- `/home/don/black-don-os/modules/core/flatpak.nix:1` - Portal configuration
- `/home/don/black-don-os/modules/home/niri/startup.nix:25-26` - Removed manual portal launches
- `/home/don/black-don-os/modules/home/niri/niri.nix:134-164` - Added systemd services (initial)
- `/home/don/black-don-os/modules/home/niri/niri.nix:134-189` - Fixed systemd services with PipeWire dependencies (final)

## How It Works

1. **Portal Configuration**: The `xdg.portal.config` section tells the system which portal backend to use for different operations. For Niri, we specify:
   - `gnome` and `gtk` as default backends
   - `gnome` specifically for ScreenCast (screen sharing)
   - `gnome` specifically for Screenshot

2. **Systemd Services**: The portal services are now managed by systemd user services, which:
   - Start automatically with the graphical session
   - Use D-Bus activation for proper integration
   - Restart automatically on failure
   - Use proper NixOS paths via `${pkgs.xdg-desktop-portal-gnome}`
   - **Wait for PipeWire to be ready** before starting (critical for screen sharing)
   - Have proper service ordering: main portal → PipeWire → portal backends

3. **Main Portal Service**: The `xdg-desktop-portal` service coordinates all backends:
   - Sets `XDG_CURRENT_DESKTOP=niri` so portals know which WM is running
   - Sets `WAYLAND_DISPLAY=wayland-1` for proper Wayland socket detection
   - Starts after PipeWire is ready to ensure audio/video capture works

4. **PipeWire Integration**: GNOME portal backend explicitly requires PipeWire:
   - `Requires = [ "pipewire.service" ]` ensures PipeWire is running
   - `After = [ "pipewire.service" ]` ensures proper startup order
   - This prevents the black screen issue by ensuring the capture backend is ready

5. **No Manual Launching**: Removed hardcoded manual launches that were:
   - Using FHS paths (`/usr/lib/...`) that don't exist in NixOS
   - Potentially conflicting with systemd service management
   - Not respecting proper service ordering

## Testing

After running `dcli rebuild` and logging back in, screen sharing should work in:
- OBS Studio
- Web browsers (Chrome, Firefox, Zen, etc.)
- Discord/Vesktop
- Any application using XDG Desktop Portal for screen capture

You should see a proper GNOME-style screen selection dialog when initiating screen sharing.

## Verification Commands

Check portal status:
```bash
# Check if all portal services are running
systemctl --user status xdg-desktop-portal
systemctl --user status xdg-desktop-portal-gnome
systemctl --user status xdg-desktop-portal-gtk

# Verify PipeWire is running
systemctl --user status pipewire

# List available portal implementations
busctl --user list | grep portal

# Check portal configuration
cat ~/.config/xdg-desktop-portal/portals.conf

# Test screen sharing works (should show actual content, not black screen)
# Try in OBS Studio, browser, or Discord
```

## Related Files

- `modules/home/niri/niri.nix` - Main Niri home-manager configuration
- `modules/home/niri/startup.nix` - Niri startup applications
- `modules/core/flatpak.nix` - System-wide portal configuration

## Notes

- The package `xdg-desktop-portal-gnome` was already installed in `modules/home/niri/niri.nix:70`
- GNOME portal provides the best Wayland screen sharing support
- GTK portal is included as fallback for other portal operations
- Keep `configPackages = [pkgs.hyprland]` for Hyprland compatibility when switching WMs
