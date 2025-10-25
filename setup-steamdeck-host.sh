#!/usr/bin/env bash

######################################
# Steam Deck Host Setup Script for Black Don OS
# Author: Black Don
# Creates a Steam Deck optimized configuration with auto-login to gamescope session
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

print_header "Black Don OS - Steam Deck Host Setup"

# Check if we're in the correct directory
if [[ ! -f "flake.nix" ]] || [[ ! -d "hosts" ]]; then
  print_error "This script must be run from the Black Don OS root directory"
  echo "Please cd to your zaneyos directory and run this script again"
  exit 1
fi

echo -e "This script will create a Steam Deck optimized host configuration."
echo -e "Features:"
echo -e "  • Greeter disabled"
echo -e "  • Auto-login to Steam gamescope session"
echo -e "  • Steam Deck hardware profile"
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
echo -e "💡 Suggested hostnames: steamdeck, gaming-deck, nixos-deck, portable-deck"
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

# Get source host to copy from
print_header "Source Configuration"
echo "Available hosts to copy base configuration from:"
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
read -rp "Username for auto-login [$currentUser]: " username
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
print_header "Creating Steam Deck Host Configuration"
echo "Creating new host directory: hosts/$newHostName"
mkdir -p "hosts/$newHostName"

# Copy base files from source host
cp "hosts/$sourceHost/default.nix" "hosts/$newHostName/"
cp "hosts/$sourceHost/host-packages.nix" "hosts/$newHostName/"

# Create Hyprland host-specific configuration directory
echo "Creating Hyprland host configuration: modules/home/hyprland/hosts/$newHostName"
mkdir -p "modules/home/hyprland/hosts/$newHostName"

# Create new variables.nix with Steam Deck specific settings
echo "Creating Steam Deck optimized variables.nix for $newHostName..."

cat > "hosts/$newHostName/variables.nix" << EOF
{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "$gitUsername";
  gitEmail = "$gitEmail";

  # Hyprland Settings
  # Steam Deck display configuration
  # The Steam Deck has a 1280x800 display at 60Hz
  extraMonitorSettings = ''
    monitor=,preferred,auto,1
  '';

  # Waybar Settings
  clock24h = false;

  # Program Options
  browser = "vivaldi"; # Set Default Browser
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # Steam Deck uses AMD APU - these IDs are not used
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Enable/Disable Features
  enableNFS = false; # Disabled for portable gaming device
  printEnable = false; # Disabled for portable gaming device
  thunarEnable = true;

  # Enable Stylix System Theming
  stylixEnable = true;
  # Set Stylix Image
  stylixImage = ../../wallpapers/Valley.jpg;

  # Waybar Choice
  waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/animations-end4.nix;

  # Steam Deck Specific Settings
  steamDeckMode = true; # Flag to enable Steam Deck optimizations
}
EOF

# Create placeholder hardware.nix with Steam Deck notes
echo "Creating Steam Deck hardware.nix template..."
cat > "hosts/$newHostName/hardware.nix" << EOF
# Hardware configuration for $newHostName (Steam Deck)
# This file will be generated by nixos-generate-config during installation
# This is just a placeholder - replace with actual hardware config

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Steam Deck uses AMD Zen 2 APU (Van Gogh)
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
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

  # Steam Deck specific hardware
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable firmware for Steam Deck hardware
  hardware.enableRedistributableFirmware = true;

  # Steam Deck audio support
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
EOF

# Create Steam Deck specific default.nix
echo "Creating Steam Deck specific default.nix..."
cat > "hosts/$newHostName/default.nix" << EOF
{
  pkgs,
  config,
  host,
  username,
  ...
}: {
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Steam Deck optimizations
  boot.kernelParams = [
    "amd_iommu=off" # Steam Deck optimization
  ];

  # Auto-login configuration for Steam gamescope session
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "\${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd gamescope-session";
        user = "$username";
      };
      initial_session = {
        command = "gamescope-session";
        user = "$username";
      };
    };
  };

  # Disable the greeter on tty1 for auto-login
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Enable Steam and gamescope
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Gaming optimizations
  programs.gamemode.enable = true;

  # Steam Deck controller support
  hardware.steam-hardware.enable = true;

  # Performance governor for gaming
  powerManagement.cpuFreqGovernor = "performance";

  # Networking
  networking.hostName = "$newHostName";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "America/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound
  sound.enable = true;

  # User account
  users.users.$username = {
    isNormalUser = true;
    description = "$username";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
  };
}
EOF

# Add Steam-specific packages to host-packages.nix
echo "Adding Steam Deck specific packages..."
cat > "hosts/$newHostName/host-packages.nix" << 'EOF'
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Steam Deck essentials
    steam
    steam-run
    gamescope
    gamemode
    mangohud

    # Controllers and input
    antimicrox

    # System utilities
    htop
    neofetch

    # Basic tools
    git
    vim
    wget
    curl
  ];
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
  # Steam Deck specific binds
  bind = [
    # Steam button replacement - Super key opens Steam
    "$modifier,S,exec,steam"

    # Quick access to game mode
    "$modifier SHIFT,G,exec,gamescope-session"
  ];

  bindm = [
    # Touch screen friendly mouse binds
  ];
}
EOF

# Create Hyprland window rules configuration
echo "Creating Hyprland window rules configuration..."
cat > "modules/home/hyprland/hosts/$newHostName/windowrules.nix" << 'EOF'
{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Steam Deck specific window rules
  windowrule = [
    # Steam in big picture mode should be fullscreen
    "fullscreen, title:^(Steam Big Picture Mode)$"
    "fullscreen, class:^(steam)$,title:^(Steam)$"

    # Games should be fullscreen
    "fullscreen, class:^(steam_app_.*)$"
  ];
}
EOF

# Update flake.nix to include the new Steam Deck host
print_header "Updating Flake Configuration"
echo "Adding $newHostName to flake.nix..."

# Backup flake.nix
cp flake.nix flake.nix.backup

# Add the new host configuration before the closing brace of nixosConfigurations
sed -i "/^      nixos-leno = mkHost/a\\      $newHostName = mkHost { hostname = \"$newHostName\"; profile = \"amd\"; username = \"$username\"; };" flake.nix

# Create installation instructions
print_header "Creating Installation Guide"
cat > "INSTALL-$newHostName.md" << EOF
# Steam Deck Installation Guide for $newHostName

## Prerequisites
- Steam Deck hardware
- Boot from NixOS minimal ISO via USB or microSD
- Ensure hostname during installation matches: **$newHostName**

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
\`\`\`bash
# Clone the repository
git clone https://gitlab.com/theblackdon/black-don-os.git
cd black-don-os
\`\`\`

### 3. Run the installation script
\`\`\`bash
# Make sure your hostname matches: $newHostName
./install-black-don-os.sh
\`\`\`

### 4. Post-installation configuration

After installation, the system will:
- Boot directly to gamescope session
- Auto-login as user: **$username**
- Start Steam in gaming mode

#### Optional: Update display settings
Edit \`hosts/$newHostName/variables.nix\` if needed:

\`\`\`nix
extraMonitorSettings = ''
  monitor=eDP-1,1280x800@60,0x0,1
  # Steam Deck native resolution
'';
\`\`\`

### 5. Verify Steam Deck Hardware
\`\`\`bash
# Check audio devices
pactl list sinks

# Check controllers
ls /dev/input/

# Verify AMD GPU
lspci | grep VGA
\`\`\`

### 6. Rebuild with updated configuration
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
- **Profile:** AMD (Steam Deck uses AMD Van Gogh APU)
- **Username:** $username
- **Auto-login:** Enabled (gamescope session)
- **Greeter:** Disabled
- **Git Name:** $gitUsername
- **Git Email:** $gitEmail

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
\`\`\`bash
systemctl --user restart pipewire
\`\`\`

### Controllers not detected
\`\`\`bash
sudo systemctl restart steam-hardware
\`\`\`

### Display issues
\`\`\`bash
# Check available displays
hyprctl monitors
# or in gamescope session:
gamescope --help
\`\`\`

## Important Notes
- The install script will generate hardware.nix automatically
- Ensure your hostname during installation matches **$newHostName** exactly
- Steam will launch automatically on boot
- Use Steam + X button to access desktop mode if needed
- Performance governor is enabled by default for gaming
EOF

print_header "Summary"
echo -e "${GREEN}✓ Created Steam Deck host configuration for: $newHostName${NC}"
echo -e "${GREEN}✓ Profile: AMD (Steam Deck APU)${NC}"
echo -e "${GREEN}✓ Auto-login: Enabled (gamescope session)${NC}"
echo -e "${GREEN}✓ Greeter: Disabled${NC}"
echo -e "${GREEN}✓ Updated flake.nix with new host${NC}"
echo -e "${GREEN}✓ Created Steam Deck optimized configs${NC}"
echo -e "${GREEN}✓ Created installation guide: INSTALL-$newHostName.md${NC}"
echo ""
echo -e "${BLUE}Files created:${NC}"
echo -e "  📁 hosts/$newHostName/"
echo -e "  📄 hosts/$newHostName/default.nix (Steam Deck optimized)"
echo -e "  📄 hosts/$newHostName/variables.nix"
echo -e "  📄 hosts/$newHostName/hardware.nix (Steam Deck template)"
echo -e "  📄 hosts/$newHostName/host-packages.nix (Gaming packages)"
echo -e "  📁 modules/home/hyprland/hosts/$newHostName/"
echo -e "  📄 modules/home/hyprland/hosts/$newHostName/binds.nix"
echo -e "  📄 modules/home/hyprland/hosts/$newHostName/windowrules.nix"
echo -e "  📄 INSTALL-$newHostName.md"
echo ""
echo -e "${YELLOW}Steam Deck Features:${NC}"
echo -e "  🎮 Auto-login to gamescope session"
echo -e "  🚫 Greeter disabled"
echo -e "  🎯 Gaming performance optimizations"
echo -e "  🎮 Steam Big Picture Mode ready"
echo -e "  🕹️  Full controller support"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Review hosts/$newHostName/variables.nix"
echo -e "2. Test the configuration: nixos-rebuild build --flake .#$newHostName"
echo -e "3. Commit your changes: git add -A && git commit -m 'Add $newHostName Steam Deck configuration'"
echo -e "4. Follow INSTALL-$newHostName.md when setting up your Steam Deck"
echo ""
echo -e "${GREEN}Ready to deploy to your Steam Deck!${NC}"
