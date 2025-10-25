# ❄️BlackDonOS Powered by NixOS❄️

A customized NixOS configuration based on [ZaneyOS](https://gitlab.com/zaney/zaneyos) by Tyler Kelley, tailored for multiple host setups with NVIDIA GPU support.

![Black Don OS Desktop](img/desktop-screenshot.png)

## Overview

Black Don OS is a personalized NixOS configuration that supports multiple host computers with different hardware profiles. It features a modern minimal desktop environment with Hyprland, extensive customization options, and easy multi-host management.

The configuration is built with modularity in mind - each host can have different features enabled or disabled (like NFS, printing, gaming controller support, Flutter development environment, etc.), custom keybinds and window rules, and personalized theming. It includes the Vicinae launcher by default for a smooth application launching experience.

## Features

- 🖥️ **Multi-Host Support** - Easy configuration management for multiple computers
- 🎮 **NVIDIA GPU Optimized** - Full support for NVIDIA graphics with proper drivers
- 📊 **Modular Bar System** - Choose between Waybar, Dank Material Shell (DMS), or Noctalia Shell for your desktop bar
- 🌊 **Hyprland Desktop** - Modern Wayland compositor with beautiful animations
- 🪟 **Niri Desktop** - Scrollable-tiling Wayland compositor as an alternative to Hyprland
- 🎨 **Stylix Integration** - System-wide theming and styling
- 📦 **Flake-based Configuration** - Reproducible and declarative system management
- 🔧 **Easy Host Setup** - Automated script for adding new computers
- ⚡ **dcli Tool** - Custom CLI utility for multi-host system management
- 🎛️ **Modular Features** - Toggle features per host (NFS, printing, gaming controllers, etc.)
- ⌨️ **Per-Host Customization** - Host-specific keybinds and window rules for Hyprland


## Installation

### For New Users

If you want to install Black Don OS on a fresh NixOS system:

1. **Boot from NixOS ISO** and ensure you have network access
2. **Install git and pciutils** (for hardware detection):
   ```shell
   nix-shell -p git pciutils
   ```
3. **Run the installation script**:
   ```shell
   sh <(curl -sL https://gitlab.com/theblackdon/black-don-os/-/raw/bdos-beta-0.3/install-black-don-os.sh)
   ```

The installer will:
- Detect your hardware (GPU, etc.)
- Guide you through hostname and user configuration
- Clone the repository and set up your configuration
- Build and install Black Don OS
- Create a personalized setup for your computer

**After Installation**: You may need to customize monitor settings and GPU IDs in your `hosts/YOUR-HOST/variables.nix` file:
- **Monitor Configuration**: Update `extraMonitorSettings` with your actual monitor setup
- **NVIDIA Prime**: Update `intelID` and `nvidiaID` with your actual GPU PCI IDs (find with `lspci | grep VGA`)
- **Wallpapers**: Choose your preferred wallpaper from the `wallpapers/` directory

### For Existing Black Don OS Users

If you already have Black Don OS and want to add a new computer:

```bash
./setup-new-host.sh
```

This will guide you through:
- Choosing a hostname
- Selecting GPU profile (nvidia, nvidia-laptop, amd, intel, vm)
- Configuring user settings
- Creating installation guide for the new computer

### Building for a Specific Host

```bash
# Using dcli (recommended)
dcli build nix-desktop      # Build only (no activation)
dcli deploy nix-desktop     # Build and switch

# Using standard nix commands
nixos-rebuild build --flake .#nix-desktop
```

### Installing on New Hardware

1. Boot NixOS installer ISO on target computer
2. Follow the host-specific installation guide (e.g., `INSTALL-nix-desktop.md`)
3. Clone this repository and run the installation commands

## Directory Structure

```
black-don-os/
├── hosts/                    # Host-specific configurations
│   ├── nixos-leno/          # Laptop configuration
│   ├── nix-desktop/         # Desktop configuration
│   └── default/             # Template host
├── profiles/                 # Hardware profiles
│   ├── nvidia/              # Desktop NVIDIA
│   ├── nvidia-laptop/       # Laptop NVIDIA/Intel hybrid
│   ├── amd/                 # AMD graphics
│   ├── intel/               # Intel graphics
│   └── vm/                  # Virtual machine
├── modules/                  # System modules
│   ├── core/                # Core system configuration
│   ├── drivers/             # Hardware drivers
│   └── home/                # Home manager configuration
├── wallpapers/              # Desktop wallpapers
├── setup-new-host.sh        # New host setup script
├── flake.nix               # Main flake configuration
└── INSTALL-*.md            # Host-specific install guides
```

## Host Configuration

Each host has its own directory under `hosts/` containing:

- `default.nix` - Main host imports
- `hardware.nix` - Hardware-specific configuration (generated by nixos-generate-config)
- `variables.nix` - Host-specific settings (monitors, GPU IDs, preferences)
- `host-packages.nix` - Host-specific package list

### Key Settings in `variables.nix`

```nix
{
  # Monitor configuration (host-specific)
  extraMonitorSettings = ''
    monitor=HDMI-A-1,3440x1440@100.0,3330x1444,1.0
    monitor=eDP-1,2560x1600@165.02,6770x1558,1.33
  '';

  # GPU IDs for NVIDIA Prime
  intelID = "PCI:34:0:0";
  nvidiaID = "PCI:1:0:0";

  # Desktop preferences
  browser = "vivaldi";
  terminal = "kitty";
  stylixImage = ../../wallpapers/Valley.jpg;

  # Modular Features (enable/disable per host)
  enableNFS = true;
  printEnable = false;
  thunarEnable = true;
  controllerSupportEnable = true;
  flutterdevEnable = false;
  stylixEnable = true;
}
```

## GPU Profiles

### NVIDIA Desktop (`nvidia`)
- Dedicated NVIDIA GPU
- No hybrid graphics
- Best for gaming desktops

### NVIDIA Laptop (`nvidia-laptop`)
- NVIDIA + Intel hybrid graphics
- NVIDIA Prime support
- Power-efficient for laptops

### AMD (`amd`)
- AMD Radeon graphics
- Open-source AMDGPU drivers

### Intel (`intel`)
- Intel integrated graphics
- Lightweight and efficient

### VM (`vm`)
- Virtual machine optimized
- Minimal graphics requirements

## Customization

### Adding a New Host

1. Run the setup script: `./setup-new-host.sh`
2. Customize `hosts/NEW-HOST/variables.nix`
3. Test build: `nixos-rebuild build --flake .#NEW-HOST`
4. Commit changes and follow installation guide

### Updating Existing Hosts

1. Edit host-specific files in `hosts/HOST-NAME/`
2. Test changes: `dcli build HOST-NAME`
3. Apply: `dcli deploy HOST-NAME` or `dcli rebuild` (for current host)

### Adding System Packages

- Edit `modules/core/packages.nix` for system-wide packages
- Edit `hosts/HOST/host-packages.nix` for host-specific packages

### Desktop Customization

- Wallpapers: Add to `wallpapers/` and reference in `variables.nix`
- Waybar themes: Choose in `variables.nix` `waybarChoice`
- Animations: Select in `variables.nix` `animChoice`
- Colors: Stylix handles theming from wallpaper

## dcli - Don CLI Utility

Black Don OS includes `dcli`, a custom command-line utility for managing your multi-host setup:

### Common Commands
```bash
dcli help           # Show all commands
dcli list-hosts     # List available hosts
dcli rebuild        # Rebuild current host
dcli update         # Update and rebuild current host
dcli build HOST     # Build specific host (no activation)
dcli deploy HOST    # Deploy to specific host
dcli cleanup        # Clean old generations
dcli switch-host    # Interactive host switcher
```

### Shell Aliases
- `fr` - Fast rebuild (`dcli rebuild`)
- `fu` - Fast update (`dcli update`)
- `hosts` - List hosts (`dcli list-hosts`)
- `switch` - Host switcher (`dcli switch-host`)

See [dcli.md](dcli.md) for complete documentation.

## Development

### Repository Management

This is a fork of ZaneyOS with personal customizations:

- **Origin**: Your fork at https://gitlab.com/theblackdon/black-don-os.git
- **Upstream**: Original ZaneyOS at https://gitlab.com/zaney/zaneyos.git

### Updating from Upstream

```bash
# Fetch updates from original ZaneyOS
dcli pull           # Pull from your fork
git fetch upstream  # Fetch from original ZaneyOS

# Merge updates (be careful with conflicts)
git merge upstream/stable-2.3
```

## Troubleshooting

### Build Failures

```bash
# Generate diagnostic report
dcli diag

# Show detailed error trace
nixos-rebuild build --flake .#HOST-NAME --show-trace

# Clean build cache
dcli cleanup
```

### Hardware Detection

```bash
# Find GPU IDs for NVIDIA Prime
lspci | grep VGA

# Generate new hardware config
sudo nixos-generate-config --show-hardware-config
```

### Monitor Configuration

```bash
# List available outputs
hyprctl monitors

# Test monitor setup
hyprctl keyword monitor "HDMI-A-1,1920x1080@60,0x0,1"
```

## Credits

- **ZaneyOS**: Original configuration by Tyler Kelley
- **NixOS**: The foundation of this configuration
- **Hyprland**: Wayland compositor
- **Stylix**: System theming
- **Home Manager**: User environment management

## License

Based on ZaneyOS, following the same license terms. See [LICENSE](LICENSE) file for details.

## Support

For issues specific to Black Don OS customizations:
- Check host-specific installation guides
- Review the troubleshooting section
- Refer to the original ZaneyOS documentation for base functionality

---

*Happy computing with Black Don OS! 🚀*
