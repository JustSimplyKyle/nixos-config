#!/usr/bin/env bash

######################################
# Install script for Black-Don-OS
# Author: Black Don (Based on ZaneyOS by Tyler Kelley)
# Date: January 2025
#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define log file
LOG_DIR="$(dirname "$0")"
LOG_FILE="${LOG_DIR}/install_$(date +"%Y-%m-%d_%H-%M-%S").log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

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

# Function to print a success banner
print_success_banner() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                Black-Don-OS Installation Successful!                  ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║   Please reboot your system for changes to take full effect.          ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print a failure banner
print_failure_banner() {
  echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                Black-Don-OS Installation Failed!                      ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║   Please review the log file for details:                             ║${NC}"
  echo -e "${RED}║   ${LOG_FILE}                                                        ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

print_header "Black-Don-OS Installation Script"
echo -e "${BLUE}Welcome to Black-Don-OS - A customized NixOS distribution${NC}"
echo -e "Based on ZaneyOS with Don's personal customizations"
echo ""

print_header "Verifying System Requirements"

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed."
  echo -e "Please install git and pciutils, then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

# Check for lspci (pciutils)
if ! command -v lspci &> /dev/null; then
  print_error "pciutils is not installed."
  echo -e "Please install git and pciutils, then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
  echo -e "${GREEN}Verified this is NixOS.${NC}"
else
  print_error "This is not NixOS or the distribution information is not available."
  exit 1
fi

print_header "Initial Setup"

echo -e "Default options are in brackets []"
echo -e "Just press enter to select the default"
sleep 2

print_header "Ensure In Home Directory"
cd "$HOME" || exit 1
echo -e "${GREEN}Current directory: $(pwd)${NC}"

print_header "Hostname Configuration"

# Critical warning about using "default" as hostname
echo -e "${RED}⚠️  IMPORTANT WARNING: Do NOT use 'default' as your hostname!${NC}"
echo -e "${RED}   The 'default' hostname is a template and will be overwritten during updates.${NC}"
echo -e "${RED}   This will cause you to lose your configuration!${NC}"
echo ""
echo -e "💡 Suggested hostnames: my-desktop, gaming-rig, workstation, nixos-laptop"
read -rp "Enter Your New Hostname: [ my-desktop ] " hostName
if [ -z "$hostName" ]; then
  hostName="my-desktop"
fi

# Double-check if user accidentally entered "default"
if [ "$hostName" = "default" ]; then
  echo -e "${RED}❌ Error: You cannot use 'default' as hostname. Please choose a different name.${NC}"
  read -rp "Enter a different hostname: " hostName
  if [ -z "$hostName" ] || [ "$hostName" = "default" ]; then
    echo -e "${RED}Setting hostname to 'my-desktop' to prevent configuration loss.${NC}"
    hostName="my-desktop"
  fi
fi

# Validate hostname format
if [[ ! "$hostName" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$ ]]; then
  print_error "Invalid hostname format. Use only letters, numbers, and hyphens."
  print_error "Setting hostname to 'my-desktop' to prevent issues."
  hostName="my-desktop"
fi

echo -e "${GREEN}✓ Hostname set to: $hostName${NC}"

print_header "GPU Profile Detection"

# Attempt automatic detection
DETECTED_PROFILE=""

has_nvidia=false
has_intel=false
has_amd=false
has_vm=false

if lspci | grep -qi 'vga\|3d'; then
  while read -r line; do
    if echo "$line" | grep -qi 'nvidia'; then
      has_nvidia=true
    elif echo "$line" | grep -qi 'amd'; then
      has_amd=true
    elif echo "$line" | grep -qi 'intel'; then
      has_intel=true
    elif echo "$line" | grep -qi 'virtio\|vmware'; then
      has_vm=true
    fi
  done < <(lspci | grep -i 'vga\|3d')

  if $has_vm; then
    DETECTED_PROFILE="vm"
  elif $has_nvidia && $has_intel; then
    DETECTED_PROFILE="nvidia-laptop"  # Hybrid systems typically use nvidia-laptop profile
  elif $has_nvidia; then
    DETECTED_PROFILE="nvidia"
  elif $has_amd; then
    DETECTED_PROFILE="amd"
  elif $has_intel; then
    DETECTED_PROFILE="intel"
  fi
fi

# Handle detected profile or fall back to manual input
if [ -n "$DETECTED_PROFILE" ]; then
  profile="$DETECTED_PROFILE"
  echo -e "${GREEN}Detected GPU profile: $profile${NC}"
  read -p "Correct? (Y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}GPU profile not confirmed. Falling back to manual selection.${NC}"
    profile="" # Clear profile to force manual input
  fi
fi

# If profile is still empty (either not detected or not confirmed), prompt manually
if [ -z "$profile" ]; then
  echo -e "${YELLOW}Manual GPU profile selection:${NC}"
  echo "Available profiles:"
  echo "  • nvidia        - Desktop with dedicated NVIDIA GPU"
  echo "  • nvidia-laptop - Laptop with hybrid NVIDIA/Intel graphics"
  echo "  • amd           - AMD graphics"
  echo "  • intel         - Intel graphics"
  echo "  • vm            - Virtual machine"
  echo ""
  read -rp "Enter Your Hardware Profile (GPU) [ amd ]: " profile
  if [ -z "$profile" ]; then
    profile="amd"
  fi
  echo -e "${GREEN}Selected GPU profile: $profile${NC}"
fi

# Validate profile is supported
valid_profiles=("amd" "nvidia" "nvidia-laptop" "intel" "vm")
if [[ ! " ${valid_profiles[@]} " =~ " ${profile} " ]]; then
  print_error "Invalid profile '$profile'. Valid options are: ${valid_profiles[*]}"
  echo -e "${RED}Please run the script again and select a valid profile.${NC}"
  exit 1
fi

print_header "Username Configuration"
installusername=$(echo $USER)
echo -e "Current username: ${GREEN}$installusername${NC}"
read -rp "Enter username for the new system [ $installusername ]: " newUsername
if [ -z "$newUsername" ]; then
  newUsername="$installusername"
fi
echo -e "${GREEN}✓ Username set to: $newUsername${NC}"

print_header "Backup Existing Black-Don-OS (if any)"

backupname=$(date +"%Y-%m-%d-%H-%M-%S")
if [ -d "black-don-os" ]; then
  echo -e "${GREEN}black-don-os exists, backing up to .config/black-don-os-backups folder.${NC}"
  if [ -d ".config/black-don-os-backups" ]; then
    echo -e "${GREEN}Moving current version of Black-Don-OS to backups folder.${NC}"
    mv "$HOME"/black-don-os .config/black-don-os-backups/"$backupname"
    sleep 1
  else
    echo -e "${GREEN}Creating the backups folder & moving Black-Don-OS to it.${NC}"
    mkdir -p .config/black-don-os-backups
    mv "$HOME"/black-don-os .config/black-don-os-backups/"$backupname"
    sleep 1
  fi
else
  echo -e "${GREEN}Thank you for choosing Black-Don-OS.${NC}"
  echo -e "${GREEN}I hope you find your time here enjoyable!${NC}"
fi

print_header "Cloning Black-Don-OS Repository"
echo -e "Cloning from: ${BLUE}https://gitlab.com/theblackdon/black-don-os.git${NC}"
git clone https://gitlab.com/theblackdon/black-don-os.git --depth=1 -b main ~/black-don-os
if [ $? -ne 0 ]; then
  print_error "Failed to clone Black-Don-OS repository"
  exit 1
fi

cd ~/black-don-os || exit 1
echo -e "${GREEN}✓ Successfully cloned Black-Don-OS${NC}"

print_header "Git Configuration"
echo "👤 Setting up git configuration for version control:"
echo "  This is needed for system updates and configuration management."
echo ""
echo -e "Current username: ${GREEN}$newUsername${NC}"
read -rp "Enter your full name for git commits [ Black Don User ]: " gitUsername
if [ -z "$gitUsername" ]; then
  gitUsername="Black Don User"
fi

echo "📧 Examples: john@example.com, jane.doe@company.org"
read -rp "Enter your email address for git commits [ $newUsername@example.com ]: " gitEmail
if [ -z "$gitEmail" ]; then
  gitEmail="$newUsername@example.com"
fi

echo -e "${GREEN}✓ Git name: $gitUsername${NC}"
echo -e "${GREEN}✓ Git email: $gitEmail${NC}"

print_header "Timezone Configuration"
echo "🌎 Common timezones:"
echo "  • US: America/New_York, America/Chicago, America/Denver, America/Los_Angeles"
echo "  • Europe: Europe/London, Europe/Berlin, Europe/Paris, Europe/Rome"
echo "  • Asia: Asia/Tokyo, Asia/Shanghai, Asia/Seoul, Asia/Kolkata"
echo "  • Australia: Australia/Sydney, Australia/Melbourne"
echo "  • UTC (Universal): UTC"
read -rp "Enter your timezone [ America/New_York ]: " timezone
if [ -z "$timezone" ]; then
  timezone="America/New_York"
fi
echo -e "${GREEN}✓ Timezone set to: $timezone${NC}"

print_header "Keyboard Layout Configuration"
echo "🌍 Common keyboard layouts:"
echo "  • us (US English) - default"
echo "  • us-intl (US International)"
echo "  • uk (UK English)"
echo "  • de (German)"
echo "  • fr (French)"
echo "  • es (Spanish)"
echo "  • it (Italian)"
echo "  • ru (Russian)"
echo "  • dvorak (Dvorak)"
read -rp "Enter your keyboard layout: [ us ] " keyboardLayout
if [ -z "$keyboardLayout" ]; then
  keyboardLayout="us"
fi
echo -e "${GREEN}✓ Keyboard layout set to: $keyboardLayout${NC}"

print_header "Console Keymap Configuration"
echo "⌨️  Console keymap (usually matches your keyboard layout):"
echo "  Most common: us, uk, de, fr, es, it, ru"
# Smart default: use keyboard layout as console keymap default if it's a common one
defaultConsoleKeyMap="$keyboardLayout"
if [[ ! "$keyboardLayout" =~ ^(us|uk|de|fr|es|it|ru|us-intl|dvorak)$ ]]; then
  defaultConsoleKeyMap="us"
fi
read -rp "Enter your console keymap: [ $defaultConsoleKeyMap ] " consoleKeyMap
if [ -z "$consoleKeyMap" ]; then
  consoleKeyMap="$defaultConsoleKeyMap"
fi
echo -e "${GREEN}✓ Console keymap set to: $consoleKeyMap${NC}"

print_header "Terminal Selection"
echo "📟 Choose your default terminal emulator:"
echo "  1. kitty       - Modern, GPU-accelerated (default)"
echo "  2. alacritty   - Fast, GPU-accelerated"
echo "  3. wezterm     - Feature-rich with multiplexing"
echo "  4. foot        - Lightweight Wayland terminal"
echo "  5. warp        - Modern with AI features"
echo ""
read -rp "Enter terminal choice [1-5] or name [ 1 ]: " terminalChoice
case "$terminalChoice" in
  1|""|kitty) terminal="kitty" ;;
  2|alacritty) terminal="alacritty" ;;
  3|wezterm) terminal="wezterm" ;;
  4|foot) terminal="foot" ;;
  5|warp) terminal="warp-terminal" ;;
  *) terminal="$terminalChoice" ;;
esac
echo -e "${GREEN}✓ Terminal set to: $terminal${NC}"

print_header "Browser Selection"
echo "🌐 Choose your default web browser:"
echo "  1. zen      - Zen browser (default)"
echo "  2. vivaldi  - Privacy-focused, customizable"
echo "  3. firefox  - Open source, privacy-focused"
echo "  4. brave    - Privacy-focused with ad blocking"
echo "  5. chromium - Open source Chrome"
echo ""
read -rp "Enter browser choice [1-5] or name [ 1 ]: " browserChoice
case "$browserChoice" in
  1|""|zen) browser="zen-browser" ;;
  2|vivaldi) browser="vivaldi" ;;
  3|firefox) browser="firefox" ;;
  4|brave) browser="brave" ;;
  5|chromium) browser="chromium" ;;
  *) browser="$browserChoice" ;;
esac
echo -e "${GREEN}✓ Browser set to: $browser${NC}"

print_header "Shell Selection"
echo "🐚 Choose your default shell:"
echo "  1. zsh     - Feature-rich with plugins (default)"
echo "  2. bash    - Traditional Unix shell"
echo "  3. fish    - User-friendly with autosuggestions"
echo "  4. nushell - Modern structured shell"
echo ""
read -rp "Enter shell choice [1-4] or name [ 1 ]: " shellChoice
case "$shellChoice" in
  1|""|zsh) userShell="zsh" ;;
  2|bash) userShell="bash" ;;
  3|fish) userShell="fish" ;;
  4|nushell|nu) userShell="nushell" ;;
  *) userShell="$shellChoice" ;;
esac
echo -e "${GREEN}✓ Shell set to: $userShell${NC}"

print_header "Bar/Shell Choice"
echo "📊 Choose your status bar/shell system:"
echo "  1. noctalia - Noctalia shell (default)"
echo "  2. dms      - DMS (Desktop Management System)"
echo "  3. waybar   - Waybar status bar"
echo ""
read -rp "Enter bar choice [1-3] or name [ 1 ]: " barChoiceInput
case "$barChoiceInput" in
  1|""|noctalia) barChoice="noctalia" ;;
  2|dms) barChoice="dms" ;;
  3|waybar) barChoice="waybar" ;;
  *) barChoice="$barChoiceInput" ;;
esac
echo -e "${GREEN}✓ Bar choice set to: $barChoice${NC}"

# If waybar is selected, also ask for the waybar theme
if [ "$barChoice" = "waybar" ]; then
  print_header "Waybar Theme Selection"
  echo "📊 Choose your Waybar theme:"
  echo "  1. jerry         - Jerry's theme (default)"
  echo "  2. ddubs         - Don's default theme"
  echo "  3. ddubs-2       - Don's alternative theme"
  echo "  4. curved        - Curved design"
  echo "  5. simple        - Minimalist design"
  echo "  6. dwm           - DWM-style theme"
  echo "  7. tony          - Tony's theme"
  echo "  8. jak-catppuccin - Catppuccin theme"
  echo "  9. nekodyke      - Nekodyke theme"
  echo ""
  read -rp "Enter waybar theme choice [1-9] [ 1 ]: " waybarThemeChoice
  case "$waybarThemeChoice" in
    1|""|jerry) waybarTheme="waybar-jerry.nix" ;;
    2|ddubs) waybarTheme="waybar-ddubs.nix" ;;
    3|ddubs-2) waybarTheme="waybar-ddubs-2.nix" ;;
    4|curved) waybarTheme="waybar-curved.nix" ;;
    5|simple) waybarTheme="waybar-simple.nix" ;;
    6|dwm) waybarTheme="waybar-dwm.nix" ;;
    7|tony) waybarTheme="waybar-tony.nix" ;;
    8|jak-catppuccin|jak) waybarTheme="waybar-jak-catppuccin.nix" ;;
    9|nekodyke) waybarTheme="waybar-nekodyke.nix" ;;
    *) waybarTheme="$waybarThemeChoice" ;;
  esac
  echo -e "${GREEN}✓ Waybar theme set to: $waybarTheme${NC}"
else
  waybarTheme="waybar-jerry.nix"  # Set a default even if not using waybar
fi

print_header "Animation Style Selection"
echo "✨ Choose your Hyprland animation style:"
echo "  1. end4     - End4's animations (default)"
echo "  2. dynamic  - Dynamic animations"
echo "  3. moving   - Moving animations"
echo "  4. def      - Default animations"
echo ""
read -rp "Enter animation choice [1-4] [ 1 ]: " animChoice
case "$animChoice" in
  1|""|end4) animStyle="animations-end4.nix" ;;
  2|dynamic) animStyle="animations-dynamic.nix" ;;
  3|moving) animStyle="animations-moving.nix" ;;
  4|def) animStyle="animations-def.nix" ;;
  *) animStyle="$animChoice" ;;
esac
echo -e "${GREEN}✓ Animation style set to: $animStyle${NC}"

print_header "Configuring Host and Profile"

# Check if hostname already exists
if [[ -d "hosts/$hostName" ]]; then
  print_warning "Host directory 'hosts/$hostName' already exists"
  read -p "Overwrite existing configuration? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 1
  fi
  rm -rf "hosts/$hostName"
fi

mkdir -p hosts/"$hostName"

# Check if we have a suitable source to copy from
if [[ -d "hosts/nixos-leno" ]]; then
  sourceHost="nixos-leno"
elif [[ -d "hosts/nix-desktop" ]]; then
  sourceHost="nix-desktop"
else
  # Find any host that's not default
  sourceHost=""
  for host_dir in hosts/*/; do
    host_name=$(basename "$host_dir")
    if [[ "$host_name" != "default" ]]; then
      sourceHost="$host_name"
      break
    fi
  done

  if [[ -z "$sourceHost" ]]; then
    print_error "No suitable source host configuration found"
    exit 1
  fi
fi

echo -e "${GREEN}Using $sourceHost as template${NC}"
cp hosts/"$sourceHost"/*.nix hosts/"$hostName"

# Set up git configuration
git config --global user.name "$gitUsername"
git config --global user.email "$gitEmail"

# Create variables.nix for new host
cat > hosts/"$hostName"/variables.nix << EOF
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
  browser = "$browser"; # Set Default Browser
  terminal = "$terminal"; # Set Default System Terminal
  defaultShell = "$userShell"; # Set Default Shell
  keyboardLayout = "$keyboardLayout";
  consoleKeyMap = "$consoleKeyMap";

  # For Nvidia Prime support (update these IDs after hardware detection)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";   # Update this with your actual integrated GPU ID
  nvidiaID = "PCI:1:0:0";  # Update this with your actual NVIDIA GPU ID

  # Enable/Disable Features
  enableNFS = true;
  printEnable = false;
  thunarEnable = true;

  # Enable Stylix System Theming
  stylixEnable = true;
  # Set Stylix Image
  stylixImage = ../../wallpapers/Valley.jpg;

  # Bar/Shell Choice
  barChoice = "$barChoice"; # Options: "dms", "noctalia", or "waybar"

  # Waybar Theme (used when barChoice = "waybar")
  waybarChoice = ../../modules/home/waybar/$waybarTheme;

  # Animation Choice
  animChoice = ../../modules/home/hyprland/$animStyle;
}
EOF

# Create host-specific Hyprland configuration files
print_header "Creating Host-Specific Hyprland Configuration"
echo -e "${GREEN}Creating Hyprland host-specific files for $hostName...${NC}"

# Create the host-specific Hyprland directory
mkdir -p modules/home/hyprland/hosts/"$hostName"

# Create default binds.nix for the new host
cat > modules/home/hyprland/hosts/"$hostName"/binds.nix << EOF
{host, ...}: let
  inherit
    (import ../../../../hosts/\${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for $hostName
  # These will be merged with the default binds
  bind = [
    # Add $hostName-specific binds here
  ];

  bindm = [
    # Add $hostName-specific mouse binds here
  ];
}
EOF

# Create default windowrules.nix for the new host
cat > modules/home/hyprland/hosts/"$hostName"/windowrules.nix << EOF
{host, ...}: let
  inherit
    (import ../../../../hosts/\${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for $hostName
  # These will be merged with the default window rules
  windowrule = [
    # Add $hostName-specific window rules here
  ];
}
EOF

echo -e "${GREEN}✓ Created Hyprland host-specific configuration files${NC}"

# Update flake.nix to add the new host
print_header "Updating Flake Configuration"

# Backup original flake.nix
cp flake.nix flake.nix.backup

# Check if the host is already in the flake
if grep -q "\"$hostName\"" flake.nix; then
  echo -e "${GREEN}Host $hostName already exists in flake.nix${NC}"
else
  # Add the new host to flake.nix
  echo -e "${GREEN}Adding $hostName to flake.nix...${NC}"

  # Create a temporary file with the new host entry
  awk -v hostname="$hostName" -v profile="$profile" -v username="$newUsername" '
    /^      # Host-specific configurations/ {
      print $0
      getline
      print $0
      print "      " hostname " = mkHost { hostname = \"" hostname "\"; profile = \"" profile "\"; username = \"" username "\"; };"
      next
    }
    { print $0 }
  ' flake.nix.backup > flake.nix
fi

# Update timezone in system.nix
if [[ -f "./modules/core/system.nix" ]]; then
  cp ./modules/core/system.nix ./modules/core/system.nix.bak
  awk -v newtz="$timezone" '/^  time\.timeZone = / { gsub(/"[^"]*"/, "\"" newtz "\""); } { print }' ./modules/core/system.nix.bak > ./modules/core/system.nix
  rm ./modules/core/system.nix.bak
  echo -e "${GREEN}✓ Updated timezone in system.nix${NC}"
fi

git add .

echo -e "${GREEN}Configuration files updated successfully!${NC}"

# Verify the updates worked
echo -e "${GREEN}Verifying configuration updates:${NC}"
echo -e "  Host: ${GREEN}$hostName${NC}"
echo -e "  Profile: ${GREEN}$profile${NC}"
echo -e "  Username: ${GREEN}$newUsername${NC}"
echo -e "  Host directory: ${GREEN}./hosts/${hostName}/${NC}"

print_header "Generating Hardware Configuration"
echo -e "${YELLOW}Note: You may see 'ERROR: cannot access /bin' - this is normal${NC}"
sudo nixos-generate-config --show-hardware-config > ./hosts/$hostName/hardware.nix

print_header "Setting Nix Configuration"
export NIX_CONFIG="experimental-features = nix-command flakes"

print_header "Pre-build Verification"
echo -e "About to build configuration with these settings:"
echo -e "  🖥️  Host: ${GREEN}$hostName${NC}"
echo -e "  🎮  GPU Profile: ${GREEN}$profile${NC}"
echo -e "  👤  Username: ${GREEN}$newUsername${NC}"
echo -e "  🌍  Timezone: ${GREEN}$timezone${NC}"
echo -e "  ⌨️   Keyboard: ${GREEN}$keyboardLayout${NC}"
echo ""
echo -e "${YELLOW}This will build and apply your Black-Don-OS configuration.${NC}"
echo -e "${YELLOW}The build process may take 10-30 minutes depending on your hardware.${NC}"
echo ""

read -p "Ready to run the build? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Build cancelled by user.${NC}"
    print_header "Manual Build Instructions"
    echo -e "You can manually build later with:"
    echo -e "${GREEN}cd ~/black-don-os${NC}"
    echo -e "${GREEN}sudo nixos-rebuild boot --flake .#$hostName${NC}"
    exit 1
fi

print_header "Building Black-Don-OS"
echo -e "${BLUE}Building configuration for $hostName...${NC}"
echo -e "${YELLOW}This may take a while - please be patient${NC}"

# Attempt the build
if sudo nixos-rebuild boot --flake .#$hostName; then
  # Clean up git config
  git config --global --unset-all user.name || true
  git config --global --unset-all user.email || true

  print_success_banner
  echo ""
  echo -e "${GREEN}🎉 Installation completed successfully!${NC}"
  echo ""
  echo -e "${BLUE}What's next:${NC}"
  echo -e "1. ${GREEN}Reboot your system${NC} to load Black-Don-OS"
  echo -e "2. Your configuration is in: ${GREEN}~/black-don-os${NC}"
  echo -e "3. To update later: ${GREEN}cd ~/black-don-os && sudo nixos-rebuild switch --flake .#$hostName${NC}"
  echo -e "4. Read the documentation: ${GREEN}~/black-don-os/README-BLACK-DON-OS.md${NC}"
  echo ""
  echo -e "${YELLOW}Enjoy your Black-Don-OS experience!${NC}"

else
  # Clean up git config even on failure
  git config --global --unset-all user.name || true
  git config --global --unset-all user.email || true

  print_failure_banner
  echo ""
  echo -e "${RED}Build failed. Common solutions:${NC}"
  echo -e "1. Check network connection and try again"
  echo -e "2. Verify hardware detection is correct"
  echo -e "3. Check the log file: $LOG_FILE"
  echo ""
  echo -e "${YELLOW}Manual retry:${NC}"
  echo -e "cd ~/black-don-os"
  echo -e "sudo nixos-rebuild boot --flake .#$hostName"
  exit 1
fi
