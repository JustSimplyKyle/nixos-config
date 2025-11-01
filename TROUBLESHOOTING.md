# Black Don OS - Troubleshooting Guide

Quick solutions for common issues with Black Don OS.

## Installation Issues

### Installation Script Fails

**Error:** Script exits with error during installation

**Common Causes:**
- Missing dependencies
- Network connectivity issues
- Invalid hostname

**Solutions:**

1. **Install required dependencies:**
   ```bash
   nix-shell -p git pciutils
   ```

2. **Check network:**
   ```bash
   ping google.com
   ```

3. **Try manual installation:**
   ```bash
   cd ~/black-don-os
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME --show-trace
   ```

### Build Failures

**Error:** `error: builder for '/nix/store/...' failed`

**Solutions:**

1. **Update flake inputs:**
   ```bash
   cd ~/black-don-os
   nix flake update
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME
   ```

2. **Check detailed errors:**
   ```bash
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME --show-trace
   ```

3. **Verify your hostname exists:**
   ```bash
   ls ~/black-don-os/hosts/
   nix flake show
   ```

### Hardware Detection Issues

**Problem:** GPU not detected correctly or display issues after installation

**Solutions:**

1. **For NVIDIA laptops with hybrid graphics:**
   ```bash
   # Find your GPU bus IDs
   lspci | grep VGA
   
   # Update in ~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix:
   intelID = "PCI:0:2:0";    # Your Intel GPU ID
   nvidiaID = "PCI:1:0:0";   # Your NVIDIA GPU ID
   
   # Rebuild
   sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
   ```

2. **Regenerate hardware config if needed:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/black-don-os/hosts/YOUR-HOSTNAME/hardware.nix
   sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
   ```

## Display Issues

### Monitor Not Working or Wrong Resolution

**Solution:** Update monitor configuration in `~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix`:

```bash
# First, find your monitors (after logging in)
hyprctl monitors  # In Hyprland
niri msg outputs  # In Niri

# Then update extraMonitorSettings in variables.nix:
extraMonitorSettings = ''
  monitor=HDMI-A-1,1920x1080@60,0x0,1
  monitor=DP-1,2560x1440@144,1920x0,1
'';

# Rebuild
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
```

### Black Screen After Login

**Possible Causes:**
- Window manager not starting
- Display configuration issue
- Graphics driver problem

**Solutions:**

1. **Switch to different window manager at login:**
   - At SDDM login screen, select Hyprland or Niri from session menu

2. **Check logs:**
   ```bash
   # Press Ctrl+Alt+F2 to get to TTY
   journalctl -xeu display-manager
   journalctl --user -xeu hyprland  # or niri
   ```

3. **Try rebuilding:**
   ```bash
   sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
   ```

## Window Manager Issues

### Can't Switch Between Hyprland and Niri

**Solution:** Both are always available! Just select at login:
1. Log out
2. At SDDM screen, click session icon (top-right or bottom-left)
3. Select "Hyprland" or "Niri"
4. Log in

No rebuild needed!

### Hyprlock Interfering with Other Lock Screens

**Problem:** Using DMS or Noctalia but hyprlock keeps activating

**Solution:** Disable hyprlock in `~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix`:

```nix
enableHyprlock = false;
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
```

## Package Issues

### Package Not Found

**Error:** `error: attribute 'packageName' missing`

**Solution:** Check if package is in nixpkgs:
```bash
# Search for package
nix search nixpkgs packagename

# If found, add to host-packages.nix or variables.nix
```

### Optional Apps Missing

**Problem:** Want Discord, extra browsers, or other apps

**Solution:** Enable optional package groups in `~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix`:

```nix
enableCommunicationApps = true;  # Discord, Teams, Zoom, Telegram
enableExtraBrowsers = true;      # Chromium, Firefox, Brave  
enableProductivityApps = true;   # Obsidian, GNOME Boxes
```

Rebuild to install:
```bash
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME
```

## System Recovery

### Boot Failure After Update

**Solution:** Boot into previous generation:

1. **At boot menu:**
   - Select "NixOS - All configurations"
   - Choose a previous generation

2. **Rollback permanently:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

### System Won't Boot At All

**Solution:** Boot from NixOS ISO and rollback:

1. Boot from NixOS installer USB
2. Mount your system:
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt  # Adjust partition as needed
   sudo mount /dev/nvme0n1p1 /mnt/boot
   ```

3. Rollback:
   ```bash
   sudo nixos-enter --root /mnt
   nixos-rebuild switch --rollback
   ```

## Network Issues

### WiFi Not Working

**Solutions:**

1. **Enable NetworkManager:**
   Already enabled by default, check status:
   ```bash
   systemctl status NetworkManager
   nmtui  # Terminal UI for network configuration
   ```

2. **Check wireless drivers:**
   ```bash
   lspci | grep -i network
   # Ensure appropriate firmware is loaded
   ```

### Bluetooth Not Working

**Solution:** Enable Bluetooth in your variables.nix (if not already enabled):

```bash
# Check current Bluetooth status
systemctl status bluetooth

# Restart if needed
sudo systemctl restart bluetooth
```

## Performance Issues

### Slow Performance or High CPU Usage

**Solutions:**

1. **Check running processes:**
   ```bash
   htop
   # or
   btop
   ```

2. **Disable animations (temporary):**
   In Hyprland: `Super+Shift+A` (if bound)

3. **Check GPU usage:**
   ```bash
   nvidia-smi  # For NVIDIA
   radeontop   # For AMD
   ```

### Screen Tearing

**Solution for NVIDIA:**

Update `~/black-don-os/hosts/YOUR-HOSTNAME/variables.nix`:
```nix
# In Hyprland settings, VRR is already configured
# Try toggling vrr setting in hyprland.nix if needed
```

## Getting More Help

### Collecting Debug Information

Before asking for help, collect this info:

```bash
# System info
uname -a
nix --version

# Hardware
lspci | grep VGA
lsblk

# Current config
cd ~/black-don-os
git log --oneline -5
ls hosts/

# Error logs
journalctl -xeu display-manager | tail -50
```

### Resources

- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **NixOS Wiki:** https://nixos.wiki/
- **Hyprland Wiki:** https://wiki.hyprland.org/
- **Niri Wiki:** https://github.com/YaLTeR/niri/wiki
- **Original ZaneyOS:** https://gitlab.com/zaney/zaneyos

## Quick Command Reference

```bash
# Rebuild current system
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME

# Test build without switching
sudo nixos-rebuild build --flake ~/black-don-os#YOUR-HOSTNAME

# Update flake inputs
cd ~/black-don-os
nix flake update

# Clean old generations
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake ~/black-don-os#YOUR-HOSTNAME

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Prevention Tips

1. **Test before switching:**
   ```bash
   nixos-rebuild build --flake .#YOUR-HOSTNAME
   # If successful, then:
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME
   ```

2. **Commit your working configs:**
   ```bash
   cd ~/black-don-os
   git add -A
   git commit -m "Working configuration"
   ```

3. **Don't use "default" as hostname** - it will be overwritten!

4. **Update regularly:**
   ```bash
   cd ~/black-don-os
   git pull
   nix flake update
   sudo nixos-rebuild switch --flake .#YOUR-HOSTNAME
   ```

---

*Can't find your issue? Check ~/black-don-os/CLAUDE.md for more technical details or consult the NixOS community.*
