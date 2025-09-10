# Installation Guide for nix-desktop

## Prerequisites
1. Install NixOS on your target computer using the minimal ISO
2. Ensure you have git and network access
3. Your target computer should have nvidia hardware

## Installation Steps

### 1. Boot from NixOS ISO and set up basic system
```bash
# Connect to network (if not using ethernet)
sudo systemctl start wpa_supplicant
sudo wpa_cli

# Partition your disk (example for UEFI)
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB
sudo parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100%
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/nvme0n1 -- set 3 esp on

# Format partitions
sudo mkfs.ext4 -L nixos /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.fat -F 32 -n boot /dev/nvme0n1p3

# Mount partitions
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
sudo swapon /dev/nvme0n1p2
```

### 2. Generate hardware configuration
```bash
sudo nixos-generate-config --root /mnt
```

### 3. Clone your configuration
```bash
cd /mnt/home
sudo mkdir -p don
sudo chown don:users don
cd don

# Install git in temporary shell
nix-shell -p git

# Clone your Black Don OS configuration
git clone https://gitlab.com/theblackdon/black-don-os.git black-don-os
cd black-don-os
```

### 4. Update hardware configuration
```bash
# Copy the generated hardware config to your host
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/nix-desktop/hardware.nix
```

### 5. Update GPU IDs (for NVIDIA systems)
```bash
# Find your GPU IDs
lspci | grep VGA

# Edit variables.nix and update the GPU IDs:
# intelID = "PCI:X:X:X";   # Your integrated GPU
# nvidiaID = "PCI:X:X:X";  # Your NVIDIA GPU
```

### 6. Update monitor configuration
Edit `hosts/nix-desktop/variables.nix` and configure your monitors in `extraMonitorSettings`.

### 7. Install the system
```bash
# Enable flakes for installation
export NIX_CONFIG="experimental-features = nix-command flakes"

# Build and install
sudo nixos-install --flake .#nix-desktop --root /mnt

# Set user password
sudo nixos-enter --root /mnt -c 'passwd don'
```

### 8. Reboot and enjoy
```bash
sudo reboot
```

## Post-Installation

After rebooting into your new system:

1. The configuration will be in `/home/don/black-don-os`
2. Make any additional customizations
3. Rebuild with: `sudo nixos-rebuild switch --flake ~/black-don-os#nix-desktop`

## Building this configuration from another computer

To build this configuration from your existing computer:
```bash
sudo nixos-rebuild switch --flake ~/black-don-os#nix-desktop
```

## Notes
- GPU Profile: nvidia
- Username: don
- Git Name: Black Don
- Git Email: rj.jones@flosstech.com

Remember to update the hardware.nix file with the actual hardware configuration from your new computer!
