# DMS Niri Startup Fix

## Issue - RESOLVED ✅
When switching to `barChoice = "dms"` in variables.nix, the DMS bar did not launch automatically on Niri startup. It could only be spawned manually from the terminal via `dms run & disown`. This also meant that all DMS IPC keybinds wouldn't work properly.

## Root Cause
The `dms` CLI binary was installed at `~/.local/bin/dms`, but it couldn't find the DMS shell files because:

1. The `dms` CLI expects the QML shell files at `~/.config/quickshell/dms`
2. The DMS flake installed them to `~/.nix-profile/etc/xdg/quickshell/dms`
3. Without this symlink connection, `dms run` would fail with "DMS is not detected as installed on this system"
4. There was also a transient duplicate `spawn-at-startup "dms" "run"` command in the generated config that was resolved by rebuilding

## Investigation Process

### What We Found
- DankMaterialShell WAS installed via nix profile: `github:AvengeMedia/DankMaterialShell`
- QML files were located at: `~/.nix-profile/etc/xdg/quickshell/dms/`
- The `dms` CLI binary was at: `~/.local/bin/dms` (installed via `dms-install` script)
- Manual installation typically clones the repo to `~/.config/quickshell/dms`
- The `dms run` command spawns quickshell with the path: `quickshell -p /home/don/.config/quickshell/dms`

### Testing
Running `dms` without the symlink:
```bash
$ dms
ERROR  go: DankMaterialShell (DMS) is not detected as installed on this system.
INFO  go: Please install DMS using dankinstall before using this management interface.
```

After creating the symlink manually:
```bash
$ mkdir -p ~/.config/quickshell
$ ln -sf ~/.nix-profile/etc/xdg/quickshell/dms ~/.config/quickshell/dms
$ dms run
# Successfully launched!
```

## Solutions Applied

### 1. Fixed the DMS Module
**File:** `modules/home/dank-material-shell/default.nix:153-155`

Added automatic symlink creation that connects the CLI to the QML files:

```nix
# Create symlink to DMS QML files from nix profile
# The dms CLI expects the shell files at ~/.config/quickshell/dms
home.file.".config/quickshell/dms".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix-profile/etc/xdg/quickshell/dms";
```

This ensures:
- The `dms` CLI can find the shell files
- `dms run` works correctly
- `dms ipc` commands function properly
- The symlink is automatically recreated on every rebuild

### 2. Niri Startup Configuration
**File:** `modules/home/niri/startup.nix:11-13`

The startup command uses `dms` directly from PATH:

```nix
barStartupCommand =
  if barChoice == "dms" then
    ''spawn-at-startup "dms" "run"''
  else if barChoice == "noctalia" then
    ''spawn-at-startup "noctalia-shell"''
  else
    ''spawn-at-startup "waybar"'';
```

This works because `~/.local/bin/dms` is in the user's PATH. The initial duplicate spawn issue was resolved by running `dcli rebuild`.

## Verification

After the fix, `dms run` output shows successful initialization:
```
dms v0.2.3
  INFO  go: Spawning quickshell with -p /home/don/.config/quickshell/dms
  INFO  go: DMS API Server listening on: /run/user/1000/danklinux-*.sock
  INFO  go: Network backend detection: NetworkManager present. Using NM API.
  INFO qml: CompositorService: Detected Niri with socket: /run/user/1000/niri.wayland-*.sock
  INFO qml: NiriService: Generated binds config at /home/don/.config/niri/dms/binds.kdl
  INFO qml: DMSService: Connected (API v11) - ["plugins","loginctl","freedesktop","gamma","bluetooth"]
```

## How DMS Works

### Installation Components
1. **Quickshell**: The shell framework that runs DMS QML code
2. **DMS QML Files**: The actual shell interface and modules
3. **dms CLI**: Go binary that manages the shell, handles IPC, and controls features

### dms CLI Functions
- `dms run`: Launches the shell (spawns quickshell with DMS config)
- `dms ipc call [module] [command]`: Send commands to running shell
- `dms greeter install`: Set up login screen integration
- `dms kill`: Stop running DMS instances

### Expected Paths
- CLI Binary: `/usr/local/bin/dms` or `~/.local/bin/dms`
- QML Files: `~/.config/quickshell/dms/`
- User Settings: `~/.config/DankMaterialShell/settings.json`
- Generated Configs: `~/.config/niri/dms/` (binds.kdl, layout.kdl)

## Next Steps

To apply these changes:
```bash
dcli rebuild
```

After rebuilding:
- DMS will automatically start when Niri launches
- All `dms ipc` commands in keybinds will work properly
- No need to manually run `dms run & disown`
- The configuration is now permanent and reproducible

## Related Files
- `modules/home/dank-material-shell/default.nix` - DMS module configuration
- `modules/home/niri/startup.nix` - Niri startup applications
- `hosts/leno-desktop/variables.nix` - Host-specific barChoice setting

## References
- DMS GitHub: https://github.com/AvengeMedia/DankMaterialShell
- Quickshell: Used as the underlying shell framework
- Installation methods: dankinstall script, manual clone, or nix flake
