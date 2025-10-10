# Dank Material Shell (DMS) Module

A home-manager module for [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell) - a modern Wayland desktop shell built with Quickshell and Go.

## Features

- **Modern Desktop Shell**: Comprehensive replacement for traditional bars/panels
- **20+ Widgets**: Including app launcher, notification center, control center, and more
- **Auto-theming**: Automatically themes GTK, QT, and terminal apps
- **Hyprland Optimized**: Specifically designed for Hyprland compositor
- **Automatic Conflict Resolution**: Automatically disables waybar when enabled

## Installation

### Per-Host Configuration

Add the following to your host's `variables.nix`:

```nix
# Enable Dank Material Shell (disables waybar automatically)
enableDankMaterialShell = true;
```

Example for `hosts/nix-desktop/variables.nix`:

```nix
{
  # ... other settings ...
  
  stylixEnable = true;
  syncthingEnable = true;
  enableDankMaterialShell = true;  # Enable DMS here
  
  # ... rest of config ...
}
```

### Rebuild

After enabling in your host variables, rebuild your system:

```bash
dcli rebuild
```

### Install DMS

Once the module is active, install the actual DMS shell:

```bash
dms-install
```

This will install DankMaterialShell via Nix profile from the upstream repository.

## What's Included

The module automatically installs:

- **Material Symbols Rounded**: Google's variable icon font (required by DMS)
- **Fira Code Nerd Font**: Programming font with icon support
- **JetBrains Mono Nerd Font**: Alternative programming font
- **Quickshell**: The shell runtime that DMS uses
- **wl-clipboard**: Wayland clipboard support
- **cliphist**: Clipboard history manager
- **brightnessctl**: Screen brightness control
- **hyprpicker**: Color picker for Hyprland
- **matugen**: Material Design color generation
- **cava**: Audio visualizer
- **Qt5/Qt6 Wayland support**: For proper rendering
- **gammastep**: Blue light filter
- **dms-install script**: Helper to install DMS from GitHub
- **dms-uninstall script**: Helper to uninstall DMS

## Configuration

DMS configuration files are located in:

```
~/.config/dms/
```

After running `dms-install`, you can customize DMS by editing files in this directory.

## Waybar Conflict Prevention

When `enableDankMaterialShell = true`, this module:

1. **Automatically disables waybar** using `lib.mkForce false`
2. Prevents both shells from running simultaneously
3. Ensures clean activation without conflicts

To switch back to waybar, simply set:

```nix
enableDankMaterialShell = false;
```

Then rebuild your system.

## Supported Compositors

- ✅ **Hyprland** (primary support)
- ✅ **Niri** (supported)
- ⚠️ Other Wayland compositors (limited support)

## Troubleshooting

### DMS not starting

1. Make sure you've run `dms-install` after enabling the module
2. Check that Hyprland is your active compositor
3. Verify DMS config exists: `ls ~/.config/dms/`

### Waybar still showing

If waybar is still active after enabling DMS:

1. Check that `enableDankMaterialShell = true` in your host's variables.nix
2. Rebuild: `dcli rebuild`
3. Restart your session

### Missing fonts or icons

The module automatically installs Material Symbols Rounded font. If icons are still missing after rebuild:

1. Verify the font is installed: `fc-list | grep -i "material symbols"`
2. Rebuild font cache: `fc-cache -fv`
3. Restart your session

If the Material Symbols Rounded font is not showing up, the error message "Please install Material Symbols Rounded and Restart your Shell" indicates the font isn't being detected. Try logging out and back in after the rebuild.

## Resources

- [DankMaterialShell GitHub](https://github.com/AvengeMedia/DankMaterialShell)
- [Quickshell Documentation](https://quickshell.outfoxxed.me/)
- [Black Don OS Documentation](../../README.md)

## Uninstalling

To remove DMS:

1. Set `enableDankMaterialShell = false` in variables.nix
2. Rebuild: `dcli rebuild`
3. Remove the profile: `nix profile remove github:AvengeMedia/DankMaterialShell`
4. Clean up config: `rm -rf ~/.config/dms/`
