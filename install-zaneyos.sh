#!/usr/bin/env bash

######################################
# Install script for zaneyos  
# Author:  Don Williams 
# Date: June 27, 2005 
#######################################

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
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

# Function to print a success banner
print_success_banner() {
  echo -e "${GREEN}╔═════��═════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                 ZaneyOS Installation Successful!                      ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}║   Please reboot your system for changes to take full effect.          ║${NC}"
  echo -e "${GREEN}║                                                                       ║${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to print a failure banner
print_failure_banner() {
  echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                 ZaneyOS Installation Failed!                          ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}║   Please review the log file for details:                             ║${NC}"
  echo -e "${RED}║   ${LOG_FILE}                                                        ║${NC}"
  echo -e "${RED}║                                                                       ║${NC}"
  echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
}

print_header "Verifying System Requirements"

# Check for git
if ! command -v git &> /dev/null; then
  print_error "Git is not installed."
  echo -e "Please install git and pciutils are installed, then re-run the install script."
  echo -e "Example: nix-shell -p git pciutils"
  exit 1
fi

# Check for lspci (pciutils)
if ! command -v lspci &> /dev/null; then
  print_error "pciutils is not installed."
  echo -e "Please install git and pciutils,  then re-run the install script."
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
echo -e "${RED}⚠️  CRITICAL WARNING: Do NOT use 'default' as your hostname!${NC}"
echo -e "${RED}   This will overwrite the template host configuration!${NC}"
echo ""
echo -e "💡 ${GREEN}Suggested hostnames:${NC}"
echo -e "   • my-desktop, my-laptop, workstation"
echo -e "   • gaming-rig, dev-machine, home-pc"
echo -e "   • Use your actual computer name or model"
echo ""
read -rp "🏷️  Enter Your New Hostname: [my-desktop] " hostName
if [ -z "$hostName" ]; then
  hostName="my-desktop"
fi
echo -e "✅ Selected hostname: ${GREEN}$hostName${NC}"

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
    DETECTED_PROFILE="nvidia-laptop"
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
  echo -e "${RED}Automatic GPU detection failed or no specific profile found.${NC}"
  printf "Enter Your Hardware Profile (GPU)\nOptions:\n[ amd ]\nnvidia\nnvidia-laptop\nintel\nvm\nPlease type out your choice: "
  read -r profile
  if [ -z "$profile" ]; then
    profile="amd"
  fi
  echo -e "${GREEN}Selected GPU profile: $profile${NC}"
fi


print_header "Backup Existing ZaneyOS (if any)"

backupname=$(date +"%Y-%m-%d-%H-%M-%S")
if [ -d "zaneyos" ]; then
  echo -e "${GREEN}zaneyos exists, backing up to .config/zaneyos-backups folder.${NC}"
  if [ -d ".config/zaneyos-backups" ]; then
    echo -e "${GREEN}Moving current version of ZaneyOS to backups folder.${NC}"
    mv "$HOME"/zaneyos .config/zaneyos-backups/"$backupname"
    sleep 1
  else
    echo -e "${GREEN}Creating the backups folder & moving ZaneyOS to it.${NC}"
    mkdir -p .config/zaneyos-backups
    mv "$HOME"/zaneyos .config/zaneyos-backups/"$backupname"
    sleep 1
  fi
else
  echo -e "${GREEN}Thank you for choosing ZaneyOS.${NC}"
  echo -e "${GREEN}I hope you find your time here enjoyable!${NC}"
fi

print_header "Cloning ZaneyOS Repository"
git clone https://gitlab.com/zaney/zaneyos.git --depth=1 -b stable-2.3  ~/zaneyos
cd ~/zaneyos || exit 1

print_header "Configuring Host and Profile"
mkdir -p hosts/"$hostName"
cp hosts/default/*.nix hosts/"$hostName"

installusername=$(echo $USER)

sed -i "/^[[:space:]]*host[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$hostName\"/" ./flake.nix
sed -i "/^[[:space:]]*profile[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$profile\"/" ./flake.nix

print_header "Timezone Configuration"
echo -e "🌍 ${GREEN}Timezone examples:${NC}"
echo -e "   • America/New_York (US Eastern)"
echo -e "   • America/Chicago (US Central)  "
echo -e "   • America/Denver (US Mountain)"
echo -e "   • America/Los_Angeles (US Pacific)"
echo -e "   • Europe/London, Europe/Paris, Europe/Berlin"
echo -e "   • Asia/Tokyo, Asia/Shanghai, Australia/Sydney"
echo ""
read -rp "🌍 Enter your timezone: [America/Chicago] " timeZone
if [ -z "$timeZone" ]; then
  timeZone="America/Chicago"
fi
echo -e "✅ Selected timezone: ${GREEN}$timeZone${NC}"
sed -i "s|time.timeZone = \".*\";|time.timeZone = \"$timeZone\";|" ./modules/core/system.nix
echo -e "✅ Updated timezone in configuration"

print_header "Git Configuration"
echo -e "📝 ${GREEN}Git configuration info:${NC}"
echo -e "   • This sets your identity for Git commits"
echo -e "   • Use your real name and email for proper attribution"
echo -e "   • This will be used for any future commits to your config"
echo ""
read -rp "📝 Enter your Git username: [Your Name] " gitUsername
if [ -z "$gitUsername" ]; then
  gitUsername="Your Name"
fi
echo -e "✅ Git username: ${GREEN}$gitUsername${NC}"
echo ""
read -rp "📧 Enter your Git email: [your.email@example.com] " gitEmail
if [ -z "$gitEmail" ]; then
  gitEmail="your.email@example.com"
fi
echo -e "✅ Git email: ${GREEN}$gitEmail${NC}"
sed -i "s/gitUsername = \".*\";/gitUsername = \"$gitUsername\";/" ./hosts/$hostName/variables.nix
sed -i "s/gitEmail = \".*\";/gitEmail = \"$gitEmail\";/" ./hosts/$hostName/variables.nix
echo -e "✅ Updated Git configuration"

print_header "Keyboard Layout Configuration"
echo -e "⌨️  ${GREEN}Common keyboard layouts:${NC}"
echo -e "   • us (US English - QWERTY)"
echo -e "   • uk (UK English)"
echo -e "   • de (German QWERTZ)"
echo -e "   • fr (French AZERTY)"
echo -e "   • es (Spanish)"
echo -e "   • it (Italian)"
echo -e "   • dvorak (Dvorak)"
echo -e "   • colemak (Colemak)"
echo ""
read -rp "⌨️  Enter your keyboard layout: [us] " keyboardLayout
if [ -z "$keyboardLayout" ]; then
  keyboardLayout="us"
fi
echo -e "✅ Selected keyboard layout: ${GREEN}$keyboardLayout${NC}"
sed -i "/^[[:space:]]*keyboardLayout[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$keyboardLayout\"/" ./hosts/$hostName/variables.nix
echo -e "✅ Updated keyboard layout in configuration"

print_header "Console Keymap Configuration"
echo -e "🗺️  ${GREEN}Console keymap info:${NC}"
echo -e "   • This sets the keyboard layout for text consoles (TTY)"
echo -e "   • Usually should match your keyboard layout above"
echo -e "   • Uses same layout names as keyboard layout"
echo ""
read -rp "🗺️  Enter your console keymap: [$keyboardLayout] " consoleKeyMap
if [ -z "$consoleKeyMap" ]; then
  consoleKeyMap="$keyboardLayout"
fi
echo -e "✅ Selected console keymap: ${GREEN}$consoleKeyMap${NC}"
sed -i "/^[[:space:]]*consoleKeyMap[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$consoleKeyMap\"/" ./hosts/$hostName/variables.nix
echo -e "✅ Updated console keymap in configuration"

print_header "Username Configuration"
echo -e "👤 Using current username: ${GREEN}$installusername${NC}"
sed -i "/^[[:space:]]*username[[:space:]]*=[[:space:]]*\"/ s/\"[^\"]*\"/\"$installusername\"/" ./flake.nix
echo -e "✅ Updated username in configuration"

print_header "Generating Hardware Configuration -- Ignore ERROR: cannot access /bin"
sudo nixos-generate-config --show-hardware-config > ./hosts/$hostName/hardware.nix

print_header "Adding new host to Git"
git add .

print_header "Setting Nix Configuration"
NIX_CONFIG="experimental-features = nix-command flakes"

print_header "Initiating NixOS Build"
read -p "Ready to run initial build? (Y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Build cancelled.${NC}"
    exit 1
fi

sudo nixos-rebuild boot --flake ~/zaneyos/#${profile}

# Check the exit status of the last command (nixos-rebuild)
if [ $? -eq 0 ]; then
  print_success_banner
else
  print_failure_banner
fi
