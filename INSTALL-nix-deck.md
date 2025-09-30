# Steam Deck Installation Guide for nix-deck

## Prerequisites
- Steam Deck hardware
- Boot from NixOS minimal ISO via USB or microSD
- Ensure hostname during installation matches: **nix-deck**

## Steam Deck Specific Features
- ✅ Greeter disabled
- ✅ Auto-login to gamescope session
- ✅ Steam Big Picture Mode optimized
- ✅ Controller support enabled
- ✅ Gaming performance optimizations

## Installation Steps

### 1. Boot from NixOS ISO
- Insert USB/microSD with NixOS minimal ISO
- Power on Steam Deck while holding Volume Down
- Select boot device from boot menu

### 2. Clone Black Don OS configuration
```bash
# Clone the repository
git clone https://gitlab.com/theblackdon/black-don-os.git
cd black-don-os
```

### 3. Run the installation script
```bash
# Make sure your hostname matches: nix-deck
./install.sh
```

### 4. Post-installation configuration

After installation, the system will:
- Boot directly to gamescope session
- Auto-login as user: **don**
- Start Steam in gaming mode

#### Optional: Update display settings
Edit `hosts/nix-deck/variables.nix` if needed:

```nix
extraMonitorSettings = ''
  monitor=eDP-1,1280x800@60,0x0,1
  # Steam Deck native resolution
'';
```

### 5. Verify Steam Deck Hardware
```bash
# Check audio devices
pactl list sinks

# Check controllers
ls /dev/input/

# Verify AMD GPU
lspci | grep VGA
```

### 6. Rebuild with updated configuration
```bash
dcli rebuild
```

## Building from Another Computer

To deploy this configuration from your existing Black Don OS computer:
```bash
dcli deploy nix-deck
```

## Configuration Details
- **Hostname:** nix-deck
- **Profile:** AMD (Steam Deck uses AMD Van Gogh APU)
- **Username:** don
- **Auto-login:** Enabled (gamescope session)
- **Greeter:** Disabled
- **Git Name:** theblackdon
- **Git Email:** theblackdonatello

## Steam Deck Optimizations
- Performance CPU governor
- AMD IOMMU disabled for better compatibility
- Steam hardware support enabled
- GameMode enabled
- MangoHUD available for performance monitoring
- Controller support via steam-hardware

## Gaming Features
- Native Steam Big Picture Mode support
- Gamescope session for optimal gaming experience
- Fullscreen window rules for games
- Controller input fully supported

## Troubleshooting

### Audio not working
```bash
systemctl --user restart pipewire
```

### Controllers not detected
```bash
sudo systemctl restart steam-hardware
```

### Display issues
```bash
# Check available displays
hyprctl monitors
# or in gamescope session:
gamescope --help
```

## Important Notes
- The install script will generate hardware.nix automatically
- Ensure your hostname during installation matches **nix-deck** exactly
- Steam will launch automatically on boot
- Use Steam + X button to access desktop mode if needed
- Performance governor is enabled by default for gaming
