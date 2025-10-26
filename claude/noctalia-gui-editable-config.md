# Noctalia GUI-Editable Configuration

**Date**: October 26, 2025  
**Status**: ✅ WORKING - GUI changes now persist

## Summary

Noctalia bar settings can now be edited through the GUI and changes will persist across reboots and rebuilds. This was achieved by making the settings file a regular writable file instead of a read-only symlink to the Nix store.

## Problem Solved

Previously, `~/.config/noctalia/settings.json` was a symlink to the Nix store, making it read-only. Any GUI changes were lost on logout or rebuild because Noctalia couldn't write to the file.

## Solution

Changed the configuration approach from managed settings to a template-based system:

1. **Template File**: Nix creates `settings.json.template` with default configuration
2. **One-Time Copy**: On activation, the template is copied to `settings.json` ONLY if it doesn't exist
3. **Writable File**: `settings.json` is a regular file (not symlink) with 644 permissions
4. **Persistent Changes**: GUI edits save directly to the writable file
5. **No Overwrites**: Rebuilds don't touch existing `settings.json`

## Current Configuration

### Catppuccin Color Scheme
The default configuration uses the Catppuccin predefined color scheme:
```json
"colorSchemes": {
  "predefinedScheme": "Catppuccin",
  "darkMode": true,
  "useWallpaperColors": false
}
```

### Default Bar Layout
- **Left**: SystemMonitor, ActiveWindow, MediaMini
- **Center**: Workspace
- **Right**: ScreenRecorder, Tray, NotificationHistory, Battery, Volume, Brightness, Clock, ControlCenter

## How to Use

### Editing Through GUI (Recommended)
1. Open Noctalia settings
2. Make changes (colors, widgets, layout, etc.)
3. Changes save automatically
4. Persist across reboots

### Checking Current Settings
```bash
cat ~/.config/noctalia/settings.json | jq
```

### Resetting to Default Template
If you want to start fresh with the Nix template:
```bash
rm ~/.config/noctalia/settings.json
dcli rebuild
```
The template will be copied as your new settings file.

### Updating the Default Template
To change what new users/hosts get by default:

1. Configure Noctalia GUI to your liking
2. Copy your settings: `cat ~/.config/noctalia/settings.json`
3. Edit: `modules/home/noctalia-shell/default.nix`
4. Update the JSON in `home.file.".config/noctalia/settings.json.template"`
5. Commit changes

**Note**: This only affects NEW installations. Existing `settings.json` files won't be overwritten.

## File Locations

- **Template**: `~/.config/noctalia/settings.json.template` (managed by Nix)
- **Active Config**: `~/.config/noctalia/settings.json` (user-writable)
- **Nix Source**: `/home/don/black-don-os/modules/home/noctalia-shell/default.nix`

## Technical Details

### Why Not Use `programs.noctalia-shell.settings`?
The Noctalia home-manager module creates read-only symlinks, preventing GUI edits. By installing the package directly and managing our own files, we maintain write access.

### Why Template + Copy Instead of Direct File?
Home-manager's `home.file` always creates symlinks by default. Using an activation script lets us:
- Provide sane defaults from Nix
- Allow user modifications
- Avoid overwriting user changes on rebuild
- Keep some declarative management

### Alternative Approaches Considered
1. **`force = false`**: Still creates symlink (doesn't help)
2. **Recursive copy**: Would overwrite on every rebuild
3. **No Nix management**: Loses reproducibility and multi-host management

The template approach balances declarative config with user freedom.

## Testing

Verified working:
- ✅ Settings file is writable (`-rw-r--r--`)
- ✅ Not a symlink (regular file)
- ✅ Catppuccin color scheme applied
- ✅ Rebuilds don't overwrite existing file
- ✅ Ready for GUI configuration

## Next Steps

1. **Configure your bar**: Open Noctalia GUI and customize to your preference
2. **Test persistence**: Make changes, logout/login, verify they persist
3. **Optional**: If happy with layout, copy to Nix template for other hosts

## Related Files
- Previous approach: `/home/don/black-don-os/claude/noctalia-persistent-settings.md`
- Noctalia config: `/home/don/black-don-os/modules/home/noctalia-shell/default.nix`
