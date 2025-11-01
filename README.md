# ❄️ Black Don OS - Powered by NixOS ❄️

A user-friendly NixOS configuration based on [ZaneyOS](https://gitlab.com/zaney/zaneyos), designed for newcomers and experienced users alike.

![Black Don OS Desktop](img/desktop-screenshot.png)

## 🌟 What is Black Don OS?

Black Don OS is a pre-configured NixOS setup that makes it easy to get started with NixOS. It features:

- 🪟 **Dual Window Managers** - Both Hyprland and Niri available at login (no rebuild needed!)
- 🎨 **Beautiful Desktop** - Modern Wayland compositors with smooth animations
- 📦 **Modular Design** - Enable only the features you need
- 🎮 **Multi-GPU Support** - NVIDIA, AMD, Intel, and hybrid laptop configurations
- 🚀 **Quick Installation** - Simple installer with sensible defaults
- 📚 **Great for Learning** - Perfect for NixOS newcomers

## ⚡ Quick Start

### Installation

1. **Boot from NixOS ISO** and ensure you have network access

2. **Install dependencies**:
   ```bash
   nix-shell -p git pciutils
   ```

3. **Clone and install**:
   ```bash
   git clone https://gitlab.com/theblackdon/black-don-os
   cd black-don-os
   ./install.sh
   ```

The installer will:
- ✅ Detect your hardware automatically
- ✅ Ask for hostname and username
- ✅ Generate hardware configuration
- ✅ Build and install Black Don OS
- ✅ Set up both Hyprland and Niri window managers

**That's it!** After installation, you can choose between Hyprland or Niri at the login screen.

### What You Get Out of the Box

- **Browser**: Zen Browser
- **Terminal**: Kitty
- **Shell**: Zsh with starship prompt
- **Bar**: Waybar with beautiful themes
- **File Manager**: Thunar
- **Window Managers**: Both Hyprland and Niri
- **Theming**: Stylix for system-wide color coordination

## 🎨 Customization

After installation, customize your system by editing:

```bash
~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix
```

### Common Customizations

#### Change Your Wallpaper
```nix
stylixImage = ../../wallpapers/Valley.jpg;  # Choose from wallpapers/ directory
```

#### Enable Optional Features
```nix
enableCommunicationApps = true;  # Discord, Teams, Zoom, Telegram
enableExtraBrowsers = true;      # Chromium, Firefox, Brave
enableProductivityApps = true;   # Obsidian, GNOME Boxes
controllerSupportEnable = true;  # Gaming controllers
```

#### Change Default Apps
```nix
browser = "firefox";    # or "vivaldi", "brave", "chromium"
terminal = "alacritty"; # or "ghostty", "kitty"
defaultShell = "fish";  # or "zsh"
```

#### Configure Your Monitors
```nix
extraMonitorSettings = ''
  monitor=HDMI-A-1,1920x1080@60,0x0,1
  monitor=DP-1,2560x1440@144,1920x0,1
'';
```

After making changes, rebuild:
```bash
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
```

## 🪟 Window Managers

Both window managers are always available - just select which one you want at login!

### Hyprland
- Modern Wayland compositor
- Beautiful animations
- Tiling window management
- Great for productivity

### Niri
- Scrollable tiling compositor
- Unique workflow
- Smooth animations
- Innovative window management

**No rebuild needed to switch!** Just log out and select the other at the login screen.

## 🎮 GPU Support

Black Don OS automatically detects and configures:

- **NVIDIA Desktop** - Full NVIDIA driver support
- **NVIDIA Laptop** - Hybrid Intel/NVIDIA with Prime
- **AMD** - Open-source AMDGPU drivers
- **Intel** - Integrated graphics
- **Virtual Machines** - Optimized for VMs

## 📁 Project Structure

```
black-don-os/
├── hosts/              # Your host configurations
│   ├── YOUR-HOST/      # Your computer's config
│   └── default/        # Template for new hosts
├── modules/
│   ├── core/          # System configuration
│   ├── drivers/       # GPU drivers
│   └── home/          # User environment (Hyprland, Niri, etc.)
├── profiles/          # Hardware profiles (nvidia, amd, intel, vm)
├── wallpapers/        # Desktop wallpapers
└── install.sh         # Simple installer
```

## 🔧 Advanced Usage

### Adding a New Computer

To install Black Don OS on another computer:

1. Clone the repo on the new machine
2. Run `./install.sh` with a different hostname
3. Your configurations are kept separate in `hosts/`

### Multiple Hosts

Each computer gets its own directory under `hosts/`:
- `hosts/my-desktop/` - Your desktop configuration  
- `hosts/my-laptop/` - Your laptop configuration

They can have completely different settings, packages, and features enabled.

### Updating Your System

```bash
cd ~/black-don-os
git pull
sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME
```

## 🆘 Troubleshooting

### Build Failures

If the build fails, try:
```bash
sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME --show-trace
```

### Monitor Not Working

Update your monitor settings in `hosts/YOUR-HOSTNAME/variables.nix`:
```bash
# Find your monitors
hyprctl monitors  # (after first login)

# Update extraMonitorSettings with correct output names
```

### NVIDIA Prime Not Working

For hybrid laptops, find your GPU IDs:
```bash
lspci | grep VGA

# Update intelID and nvidiaID in variables.nix
```

### Hyprlock Conflicting with Other Lock Screens

If using DMS or Noctalia lock screens:
```nix
enableHyprlock = false;  # in variables.nix
```

## 💡 Tips for NixOS Newcomers

- **Everything is declarative** - Your entire system is defined in text files
- **Rebuilding is safe** - If something breaks, boot into the previous generation
- **No reinstall needed** - Just edit files and rebuild
- **Git is your friend** - Commit your changes to track your configuration history
- **Read the variables** - Most customization happens in `variables.nix`

## 🤝 Getting Help

- Check `hosts/default/variables.nix` for all available options
- Read the [NixOS Wiki](https://nixos.wiki/)
- Visit [NixOS Discourse](https://discourse.nixos.org/)
- Check original [ZaneyOS documentation](https://gitlab.com/zaney/zaneyos)

## 📜 Credits

- **ZaneyOS** - Original configuration by Tyler Kelley
- **NixOS** - The amazing Linux distribution
- **Hyprland** - Modern Wayland compositor  
- **Niri** - Innovative scrollable compositor
- **Stylix** - System-wide theming

## 📄 License

Based on ZaneyOS. See [LICENSE](LICENSE) for details.

---

**Enjoy your Black Don OS experience!** 🚀

*Made with ❤️ for the NixOS community*
