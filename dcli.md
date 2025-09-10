# Don CLI (dcli) - Version 2.0.0

dcli is a command-line utility for managing your Black Don OS multi-host setup with ease. It provides convenient commands for system management, multi-host operations, and maintenance tasks.

## Usage

Run the utility with a specific command:

`dcli [command] [options]`

If no command is provided, it displays the help message.

## Available Commands

### System Commands

| Command        | Description                                                                               | Example Usage                    |
| -------------- | ----------------------------------------------------------------------------------------- | -------------------------------- |
| rebuild        | Rebuild the NixOS system configuration for current host                                   | `dcli rebuild`                   |
| rebuild-boot   | Rebuild and set as boot default (activates on next restart)                              | `dcli rebuild-boot`              |
| update         | Update the flake and rebuild the system for current host                                  | `dcli update`                    |
| switch-host    | Interactive host switcher (same as ./switch-host.sh)                                     | `dcli switch-host`               |

### Multi-Host Commands

| Command        | Description                                                                               | Example Usage                    |
| -------------- | ----------------------------------------------------------------------------------------- | -------------------------------- |
| build [HOST]   | Build configuration for specific host (no activation)                                    | `dcli build nix-desktop`         |
| deploy [HOST]  | Build and switch to specific host configuration                                           | `dcli deploy nix-desktop`        |
| list-hosts     | List all available host configurations                                                    | `dcli list-hosts`                |

### Maintenance Commands

| Command        | Description                                                                               | Example Usage                    |
| -------------- | ----------------------------------------------------------------------------------------- | -------------------------------- |
| cleanup        | Clean up old system generations. Can specify a number to keep                            | `dcli cleanup`                   |
| diag           | Create a system diagnostic report (saves to ~/diag.txt)                                  | `dcli diag`                      |
| list-gens      | List user and system generations                                                          | `dcli list-gens`                 |
| trim           | Trim filesystems to improve SSD performance                                               | `dcli trim`                      |

### Git Commands

| Command        | Description                                                                               | Example Usage                    |
| -------------- | ----------------------------------------------------------------------------------------- | -------------------------------- |
| commit [msg]   | Add all changes and commit with message                                                   | `dcli commit "Add new feature"`  |
| push           | Push changes to origin                                                                    | `dcli push`                      |
| pull           | Pull latest changes from origin                                                           | `dcli pull`                      |
| status         | Show git status                                                                           | `dcli status`                    |

## Shell Aliases

dcli comes with convenient shell aliases for common operations:

| Alias    | Command            | Description                                |
| -------- | ------------------ | ------------------------------------------ |
| `fr`     | `dcli rebuild`     | Fast rebuild current host                  |
| `fu`     | `dcli update`      | Fast update and rebuild current host       |
| `rebuild`| `dcli rebuild`     | Rebuild current host                       |
| `update` | `dcli update`      | Update and rebuild current host            |
| `cleanup`| `dcli cleanup`     | Clean up old generations                   |
| `hosts`  | `dcli list-hosts`  | List available hosts                       |
| `switch` | `dcli switch-host` | Interactive host switcher                  |

## Detailed Command Descriptions

### System Commands

- **🔨 rebuild**: Performs a system rebuild for the current host. It automatically detects your hostname and rebuilds the appropriate configuration. Includes backup file cleanup before rebuilding.

- **🥾 rebuild-boot**: Similar to rebuild, but sets the new configuration as the boot default without immediately switching to it. Changes will take effect on next restart.

- **🔄 update**: Updates your flake inputs to the latest versions, then rebuilds the system. This ensures you get the latest packages and security updates.

- **🔀 switch-host**: Launches the interactive host switcher script, allowing you to easily switch between different host configurations.

### Multi-Host Commands

- **🔨 build [HOST]**: Builds a configuration for the specified host without activating it. Useful for testing configurations or preparing for deployment. Example: `dcli build nix-desktop`

- **🚀 deploy [HOST]**: Builds and immediately switches to the specified host configuration. Use with caution as it will change your current system configuration. Example: `dcli deploy nix-desktop`

- **📋 list-hosts**: Shows all available host configurations in your setup. Marks the current host configuration for easy identification.

### Maintenance Commands

- **🧹 cleanup**: Manages system storage by removing old generations. You can choose to remove all old generations or specify a number to keep. This helps free up disk space and clean up the boot menu.

- **🛠️ diag**: Creates a comprehensive diagnostic report including system information, git status, and host configurations. The report is saved to `~/diag.txt` and is useful for troubleshooting or sharing system details.

- **📋 list-gens**: Displays current user and system generations, helping you understand what's installed and plan cleanup operations.

- **✂️ trim**: Optimizes filesystems, particularly beneficial for SSDs. Improves performance and reduces wear by trimming unused blocks.

### Git Commands

- **📝 commit [message]**: Adds all changes in your Black Don OS directory and commits them with the specified message. If no message is provided, you'll be prompted to enter one.

- **⬆️ push**: Pushes your committed changes to your GitLab fork. Automatically detects the current branch.

- **⬇️ pull**: Pulls the latest changes from your GitLab fork to keep your local copy up to date.

- **📊 status**: Shows the current git status of your Black Don OS directory, including modified files and branch information.

## Multi-Host Workflow Examples

### Preparing a New Host Configuration
```bash
# List available hosts
dcli list-hosts

# Build configuration for new host (test without deploying)
dcli build nix-desktop

# If build successful, deploy to the target system
dcli deploy nix-desktop
```

### Managing Multiple Computers
```bash
# On your laptop (nixos-leno)
fr                    # Quick rebuild current host

# Switch to desktop configuration (if managing remotely)
dcli deploy nix-desktop

# Interactive switching
switch                # or dcli switch-host
```

### Maintenance Routine
```bash
# Update system
fu                    # Fast update (dcli update)

# Clean up old generations
cleanup               # dcli cleanup

# Trim SSD
dcli trim

# Check system status
dcli diag
```

### Development Workflow
```bash
# Make changes to configuration files
# ...

# Check what changed
dcli status

# Commit changes
dcli commit "Updated desktop configuration"

# Test build
dcli build nix-desktop

# Push to repository
dcli push

# Deploy to target system
dcli deploy nix-desktop
```

## Configuration

dcli automatically detects:
- **Current Host**: From the system hostname
- **Project Directory**: `~/black-don-os`
- **Available Hosts**: From the `hosts/` directory
- **Current Profile**: From your flake configuration

## Troubleshooting

### Build Failures
```bash
# Generate diagnostic report
dcli diag

# Check git status
dcli status

# List available hosts
dcli list-hosts

# Try building specific host
dcli build [hostname]
```

### Host Not Found
If you get "Host not found" errors:
1. Check available hosts: `dcli list-hosts`
2. Ensure you're in the correct directory
3. Verify the host directory exists in `hosts/`

### Permission Issues
Some commands require sudo privileges:
- `dcli rebuild`
- `dcli deploy [HOST]` 
- `dcli trim`

### Git Issues
If git commands fail:
1. Check you're in the correct directory: `dcli status`
2. Ensure you have proper Git credentials configured
3. Verify your remote is set up correctly

## Migration from zcli

If you were previously using ZaneyOS's `zcli`, here are the key differences:

| Old Command | New Command | Notes |
| ----------- | ----------- | ----- |
| `zcli rebuild` | `dcli rebuild` | Now works with proper hostname detection |
| `zcli update` | `dcli update` | Same functionality, better multi-host support |
| `fr` (old) | `fr` (new) | Now uses `dcli rebuild` instead of direct `nh` |
| `fu` (old) | `fu` (new) | Now uses `dcli update` instead of direct `nh` |
| N/A | `dcli build [HOST]` | New: Build specific host configurations |
| N/A | `dcli deploy [HOST]` | New: Deploy to specific hosts |
| N/A | `dcli list-hosts` | New: List available hosts |

## Version History

- **2.0.0**: Complete rewrite for Black Don OS multi-host support
  - Added multi-host commands (`build`, `deploy`, `list-hosts`)
  - Improved git integration
  - Better error handling and validation
  - Host-aware operations
  - Enhanced diagnostics

- **1.0.1**: Original ZaneyOS zcli version

---

*Happy computing with Black Don OS! 🚀*