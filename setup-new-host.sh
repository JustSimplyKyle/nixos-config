#!/usr/bin/env bash

######################################
# New Host Setup Script for Black Don OS
# Author: Black Don
# Based on ZaneyOS by Don Williams
#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print a section header
print_header() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ ${1} ${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print an error message
print_error() {
  echo -e "${RED}Error: ${1}${NC}"
}

# Function to print a warning message
print_warning() {
  echo -e "${YELLOW}Warning: ${1}${NC}"
}

print_header "Black Don OS - New Host Setup"

# Check if we're in the correct directory
if [[ ! -f "flake.nix" ]] || [[ ! -d "hosts" ]]; then
  print_error "This script must be run from the Black Don OS root directory"
  echo "Please cd to your zaneyos directory and run this script again"
  exit 1
fi

echo -e "This script will help you set up a new host configuration."
echo -e "You can use this to prepare configs for additional computers."
echo ""

# Get new hostname
print_header "Hostname Configuration"
echo -e "${RED}⚠️  IMPORTANT: Do NOT use 'default' as your hostname!${NC}"
echo -e "${RED}   Also avoid these existing hostnames:${NC}"
for existing_host in hosts/*/; do
  hostname=$(basename "$existing_host")
  echo -e "${RED}   - ${hostname}${NC}"
done
echo ""
echo -e "💡 Suggested hostnames: gaming-desktop, workstation, nixos-tower, media-center"
read -rp "Enter new hostname: " newHostName

# Validate hostname
if [[ -z "$newHostName" ]]; then
  print_error "Hostname cannot be empty"
  exit 1
fi

if [[ "$newHostName" == "default" ]]; then
  print_error "Cannot use 'default' as hostname"
  exit 1
fi

if [[ -d "hosts/$newHostName" ]]; then
  print_error "Host '$newHostName' already exists"
  exit 1
fi

# Validate hostname format
if [[ ! "$newHostName" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$ ]]; then
  print_error "Invalid hostname format. Use only letters, numbers, and hyphens."
  exit 1
fi

echo -e "${GREEN}✓ Hostname: $newHostName${NC}"

# Get GPU profile
print_header "GPU Profile Selection"
echo "Available profiles:"
echo "  • nvidia        - Desktop with dedicated NVIDIA GPU"
echo "  • nvidia-laptop - Laptop with hybrid NVIDIA/Intel graphics"
echo "  • amd           - AMD graphics"
echo "  • intel         - Intel graphics"
echo "  • vm            - Virtual machine"

read -rp "Enter GPU profile [nvidia]: " gpuProfile
if [[ -z "$gpuProfile" ]]; then
  gpuProfile="nvidia"
fi

# Validate profile
valid_profiles=("amd" "nvidia" "nvidia-laptop" "intel" "vm")
if [[ ! " ${valid_profiles[@]} " =~ " ${gpuProfile} " ]]; then
  print_error "Invalid profile '$gpuProfile'. Valid options: ${valid_profiles[*]}"
  exit 1
fi

echo -e "${GREEN}✓ GPU Profile: $gpuProfile${NC}"

# Get source host to copy from
print_header "Source Configuration"
echo "Available hosts to copy configuration from:"
for existing_host in hosts/*/; do
  hostname=$(basename "$existing_host")
  if [[ "$hostname" != "default" ]]; then
    echo "  • $hostname"
  fi
done

read -rp "Copy configuration from host [nixos-leno]: " sourceHost
if [[ -z "$sourceHost" ]]; then
  sourceHost="nixos-leno"
fi

if [[ ! -d "hosts/$sourceHost" ]]; then
  print_error "Source host '$sourceHost' does not exist"
  exit 1
fi

echo -e "${GREEN}✓ Source host: $sourceHost${NC}"

# User details
print_header "User Configuration"
currentUser=$(whoami)
read -rp "Username [$currentUser]: " username
if [[ -z "$username" ]]; then
  username="$currentUser"
fi

read -rp "Full name for git [Black Don]: " gitUsername
if [[ -z "$gitUsername" ]]; then
  gitUsername="Black Don"
fi

read -rp "Email for git [rj.jones@flosstech.com]: " gitEmail
if [[ -z "$gitEmail" ]]; then
  gitEmail="rj.jones@flosstech.com"
fi

echo -e "${GREEN}✓ Username: $username${NC}"
echo -e "${GREEN}✓ Git name: $gitUsername${NC}"
echo -e "${GREEN}✓ Git email: $gitEmail${NC}"

# Create new host directory
print_header "Creating Host Configuration"
echo "Creating new host directory: hosts/$newHostName"
mkdir -p "hosts/$newHostName"

# Copy base files from source host
cp "hosts/$sourceHost/default.nix" "hosts/$newHostName/"
cp "hosts/$sourceHost/host-packages.nix" "hosts/$newHostName/"

# Create Hyprland host-specific configuration directory
echo "Creating Hyprland host configuration: modules/home/hyprland/hosts/$newHostName"
mkdir -p "modules/home/hyprland/hosts/$newHostName"

# Create new variables.nix based on source but with new hostname-specific settings
echo "Creating variables.nix for $newHostName..."

cat > "hosts/$newHostName/variables.nix" << EOF
{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "$gitUsername";
  gitEmail = "$gitEmail";

  # Hyprland Settings
  # Configure your monitors here - this is host-specific
  # ex "monitor=HDMI-A-1, 1920x1080@60,auto,1"
  # You'll need to update this after installation based on your actual monitors
  extraMonitorSettings = ''
    monitor=,preferred,auto,1
  '';

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "vivaldi"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support (update these IDs after hardware detection)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";   # Update this with your actual integrated GPU ID
  nvidiaID = "PCI:1:0:0";  # Update this with your actual NVIDIA GPU ID

  # Enable/Disable Features
  enableNFS = true;
  printEnable = false;
  thunarEnable = true;

  # Styling
  stylixImage = ../../wallpapers/Valley.jpg;

  # Waybar Choice
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/animations-end4.nix;
}
EOF

# Create placeholder hardware.nix
echo "Creating placeholder hardware.nix..."
cat > "hosts/$newHostName/hardware.nix" << EOF
# Hardware configuration for $newHostName
# This file will be generated by nixos-generate-config during installation
# This is just a placeholder - replace with actual hardware config

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Placeholder configuration - update after installation
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd" for AMD CPUs
  boot.extraModulePackages = [ ];

  # Placeholder filesystem config - update with actual UUIDs after installation
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Update this based on your CPU
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
EOF

# Create Hyprland binds configuration
echo "Creating Hyprland binds configuration..."
cat > "modules/home/hyprland/hosts/$newHostName/binds.nix" << 'EOF'
{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for $newHostName
  # These will be merged with the default binds
  bind = [
    # Add your host-specific keybinds here
    # Example: "$modifier SHIFT,A,exec,some-app"
  ];

  bindm = [
    # Add your host-specific mouse binds here
  ];
}
EOF

# Replace the placeholder hostname in the binds file
sed -i "s/\$newHostName/$newHostName/g" "modules/home/hyprland/hosts/$newHostName/binds.nix"

# Create Hyprland window rules configuration
echo "Creating Hyprland window rules configuration..."
cat > "modules/home/hyprland/hosts/$newHostName/windowrules.nix" << 'EOF'
{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for $newHostName
  # These will be merged with the default window rules
  windowrule = [
    # Add your host-specific window rules here
    # Example: "float, class:^(some-app)$"
    # Example: "tile, class:^(another-app)$"
  ];
}
EOF

# Replace the placeholder hostname in the window rules file
sed -i "s/\$newHostName/$newHostName/g" "modules/home/hyprland/hosts/$newHostName/windowrules.nix"

# Update flake.nix to include the new host
print_header "Updating Flake Configuration"
echo "Adding $newHostName to flake.nix..."

# Backup flake.nix
cp flake.nix flake.nix.backup

# Create a simple function to add the new host to nixosConfigurations
cat > flake.nix << 'EOF'
{
  description = "Black Don OS (Based on ZaneyOS)";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/release-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {nixpkgs, nixpkgs-unstable, flake-utils, ...} @ inputs: let
    system = "x86_64-linux";

    # Helper function to create a host configuration
    mkHost = {hostname, profile, username}: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        host = hostname;
        inherit profile;
        inherit username;
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [./profiles/${profile}];
    };

  in {
    nixosConfigurations = {
      # GPU-based configurations (legacy)
      amd = mkHost { hostname = "nixos-leno"; profile = "amd"; username = "don"; };
      nvidia = mkHost { hostname = "nixos-leno"; profile = "nvidia"; username = "don"; };
      nvidia-laptop = mkHost { hostname = "nixos-leno"; profile = "nvidia-laptop"; username = "don"; };
      intel = mkHost { hostname = "nixos-leno"; profile = "intel"; username = "don"; };
      vm = mkHost { hostname = "nixos-leno"; profile = "vm"; username = "don"; };

      # Host-specific configurations
      nixos-leno = mkHost { hostname = "nixos-leno"; profile = "nvidia-laptop"; username = "don"; };
EOF

# Add the new host configuration
cat >> flake.nix << EOF
      $newHostName = mkHost { hostname = "$newHostName"; profile = "$gpuProfile"; username = "$username"; };
EOF

# Close the nixosConfigurations and add the devShells
cat >> flake.nix << 'EOF'
    };

    # Flutter development environment
    devShells = flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs-unstable {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolsVersion = "33.0.2";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ buildToolsVersion ];
          platformVersions = [ "33" ];
          abiVersions = [ "arm64-v8a" ];
        };
        androidSdk = androidComposition.androidsdk;
      in
      {
        default = with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            flutter
            androidSdk
            jdk11
          ];
        };
      });
  };
}
EOF

# Create installation instructions
print_header "Creating Installation Guide"
cat > "INSTALL-$newHostName.md" << EOF
# Installation Guide for $newHostName

## Prerequisites
- Boot from NixOS minimal ISO (which includes git and network tools)
- Target computer should have $gpuProfile hardware
- Ensure hostname during installation matches: **$newHostName**

## Installation Steps

### 1. Clone Black Don OS configuration
\`\`\`bash
# Clone the repository
git clone https://gitlab.com/theblackdon/black-don-os.git
cd black-don-os
\`\`\`

### 2. Run the installation script
\`\`\`bash
# Make sure your hostname matches the one you created: $newHostName
./install.sh
\`\`\`

### 3. Post-installation configuration

After installation, update the following in \`hosts/$newHostName/variables.nix\`:

**Monitor Configuration:**
\`\`\`nix
extraMonitorSettings = ''
  monitor=HDMI-A-1,1920x1080@60,0x0,1
  # Add your actual monitor configuration
'';
\`\`\`

**GPU IDs (for NVIDIA systems only):**
\`\`\`bash
# Find your GPU IDs
lspci | grep VGA

# Update in variables.nix:
intelID = "PCI:0:2:0";   # Your integrated GPU
nvidiaID = "PCI:1:0:0";  # Your NVIDIA GPU
\`\`\`

### 4. Rebuild with updated configuration
\`\`\`bash
dcli rebuild
\`\`\`

## Building from Another Computer

To deploy this configuration from your existing Black Don OS computer:
\`\`\`bash
dcli deploy $newHostName
\`\`\`

## Configuration Details
- **Hostname:** $newHostName
- **GPU Profile:** $gpuProfile
- **Username:** $username
- **Git Name:** $gitUsername
- **Git Email:** $gitEmail

## Important Notes
- The install script will generate hardware.nix automatically
- Ensure your hostname during installation matches **$newHostName** exactly
- Update monitor settings and GPU IDs after first boot
- Use \`dcli\` commands for system management
EOF

print_header "Summary"
echo -e "${GREEN}✓ Created host configuration for: $newHostName${NC}"
echo -e "${GREEN}✓ GPU Profile: $gpuProfile${NC}"
echo -e "${GREEN}✓ Updated flake.nix with new host${NC}"
echo -e "${GREEN}✓ Created Hyprland host-specific configs${NC}"
echo -e "${GREEN}✓ Created installation guide: INSTALL-$newHostName.md${NC}"
echo ""
echo -e "${BLUE}Files created:${NC}"
echo -e "  📁 hosts/$newHostName/"
echo -e "  📄 hosts/$newHostName/default.nix"
echo -e "  📄 hosts/$newHostName/variables.nix"
echo -e "  📄 hosts/$newHostName/hardware.nix (placeholder)"
echo -e "  📄 hosts/$newHostName/host-packages.nix"
echo -e "  📁 modules/home/hyprland/hosts/$newHostName/"
echo -e "  📄 modules/home/hyprland/hosts/$newHostName/binds.nix"
echo -e "  📄 modules/home/hyprland/hosts/$newHostName/windowrules.nix"
echo -e "  📄 INSTALL-$newHostName.md"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review and customize hosts/$newHostName/variables.nix"
echo -e "2. Test the configuration: nixos-rebuild build --flake .#$newHostName"
echo -e "3. Commit your changes: git add -A && git commit -m 'Add $newHostName host configuration'"
echo -e "4. Follow INSTALL-$newHostName.md when setting up the new computer"
echo ""
echo -e "${GREEN}Ready for deployment to your second computer!${NC}"
