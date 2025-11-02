#!/usr/bin/env bash

######################################
# Black Don OS - Simplified Installer
# A NixOS configuration for everyone
######################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
print_header() {
  echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║ ${1}${NC}"
  echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

print_error() {
  echo -e "${RED}✗ Error: ${1}${NC}"
}

print_success() {
  echo -e "${GREEN}✓ ${1}${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ ${1}${NC}"
}

# Welcome
clear
print_header "Black Don OS - Simplified Installation"
echo ""
echo -e "${BLUE}Welcome! This installer will set up Black Don OS with sensible defaults.${NC}"
echo -e "${BLUE}You can customize everything later by editing your variables.nix file.${NC}"
echo ""
sleep 2

# Verify NixOS
print_header "System Verification"
if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
  print_success "Running on NixOS"
else
  print_error "This installer requires NixOS"
  exit 1
fi

# Check dependencies
if ! command -v git &> /dev/null || ! command -v lspci &> /dev/null; then
  print_error "Missing dependencies. Please run:"
  echo -e "  ${GREEN}nix-shell -p git pciutils${NC}"
  exit 1
fi
print_success "All dependencies found"
echo ""

# Get hostname
print_header "Hostname Configuration"
echo -e "${YELLOW}⚠️  Do NOT use 'default' as your hostname!${NC}"
echo -e "Suggested names: my-desktop, nixos-laptop, gaming-rig"
echo ""

while true; do
  read -p "Enter hostname [nixos-desktop]: " hostname
  hostname=${hostname:-nixos-desktop}

  if [ "$hostname" = "default" ]; then
    print_error "Cannot use 'default' as hostname. Choose something else."
    continue
  fi

  if [[ ! "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
    print_error "Invalid hostname. Use only letters, numbers, and hyphens."
    continue
  fi

  break
done

print_success "Hostname: $hostname"
echo ""

# Get username
print_header "User Configuration"
current_user=$(echo $USER)
read -p "Enter username [$current_user]: " username
username=${username:-$current_user}
print_success "Username: $username"
echo ""

# Detect GPU
print_header "Hardware Detection"
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

if [ -z "$DETECTED_PROFILE" ]; then
  echo -e "${YELLOW}Could not detect GPU automatically${NC}"
  echo "Available profiles: nvidia, nvidia-laptop, amd, intel, vm"
  read -p "Enter GPU profile [amd]: " profile
  profile=${profile:-amd}
else
  echo -e "Detected GPU: ${GREEN}$DETECTED_PROFILE${NC}"
  read -p "Is this correct? [Y/n]: " confirm
  if [[ $confirm =~ ^[Nn]$ ]]; then
    echo "Available profiles: nvidia, nvidia-laptop, amd, intel, vm"
    read -p "Enter GPU profile: " profile
  else
    profile=$DETECTED_PROFILE
  fi
fi

print_success "GPU Profile: $profile"
echo ""

# Configuration summary
print_header "Configuration Summary"
echo -e "  Hostname:      ${GREEN}$hostname${NC}"
echo -e "  Username:      ${GREEN}$username${NC}"
echo -e "  GPU Profile:   ${GREEN}$profile${NC}"
echo ""
echo -e "${BLUE}Default Settings (you can change these later):${NC}"
echo -e "  Browser:       zen"
echo -e "  Terminal:      kitty"
echo -e "  Shell:         zsh"
echo -e "  Bar:           waybar"
echo -e "  Window Mgrs:   Both Hyprland and Niri (choose at login)"
echo -e "  Timezone:      America/New_York"
echo -e "  Keyboard:      us"
echo ""

read -p "Continue with installation? [Y/n]: " proceed
if [[ $proceed =~ ^[Nn]$ ]]; then
  echo "Installation cancelled"
  exit 0
fi

# Generate hardware config
print_header "Generating Hardware Configuration"
sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix
print_success "Hardware configuration generated"
echo ""

# Create host directory
print_header "Creating Host Configuration"
mkdir -p "hosts/$hostname"

# Copy default template
cp hosts/default/*.nix "hosts/$hostname/" 2>/dev/null || true

# Copy hardware config
mv /tmp/hardware.nix "hosts/$hostname/hardware.nix"

# Create variables.nix
cat > "hosts/$hostname/variables.nix" << EOF
{
  # Git Configuration
  gitUsername = "$username";
  gitEmail = "$username@$hostname";

  # Monitor Settings (update after installation for your displays)
  extraMonitorSettings = ''
    monitor=,preferred,auto,1
  '';

  # Hyprland Plugin Settings
  hyprexpoSettings = {
    columns = 2;
    gap_size = 5;
    bg_col = "rgb(111111)";
    workspace_method = "center current";
    skip_empty = true;
    enable_gesture = true;
    gesture_fingers = 3;
    gesture_distance = 300;
    gesture_positive = true;
  };

  hyprscrollingSettings = {
    column_default_width = "onehalf";
    column_widths = "onehalf one";
    fullscreen_on_one_column = true;
    focus_fit_method = 1;
  };

  # Waybar Settings
  clock24h = false;

  # Default Applications
  browser = "zen";
  terminal = "kitty";
  keyboardLayout = "us";
  consoleKeyMap = "us";

  # For Nvidia Prime support (update if using nvidia-laptop profile)
  # Run 'lspci | grep VGA' to find your actual GPU IDs
  intelID = "PCI:0:2:0";
  nvidiaID = "PCI:1:0:0";

  # Core Features
  enableNFS = false;
  printEnable = false;
  thunarEnable = true;
  stylixEnable = true;

  # Optional Features (disabled for faster initial install)
  # You can enable these later by setting to true and rebuilding
  gamingSupportEnable = false;       # Gaming controllers, gamescope, protonup-qt
  flutterdevEnable = false;          # Flutter development environment
  syncthingEnable = false;           # Syncthing file synchronization
  enableCommunicationApps = false;   # Discord, Teams, Zoom, Telegram
  enableExtraBrowsers = false;       # Vivaldi, Brave, Firefox, Chromium, Helium
  enableProductivityApps = false;    # Obsidian, GNOME Boxes, QuickEmu
  aiCodeEditorsEnable = false;       # Claude-code, gemini-cli, cursor

  # Desktop Environment
  enableHyprlock = true;  # Set to false if using DMS/Noctalia lock screens
  barChoice = "waybar";
  defaultShell = "zsh";

  # Theming
  stylixImage = ../../wallpapers/Valley.jpg;
  waybarChoice = ../../modules/home/waybar/waybar-jerry.nix;
  animChoice = ../../modules/home/hyprland/animations-end4.nix;

  # Startup Applications
  startupApps = [];
}
EOF

print_success "Host configuration created"
echo ""

# Create Hyprland host-specific configuration files
print_header "Creating Window Manager Host Configurations"
mkdir -p "modules/home/hyprland/hosts/$hostname"

# Create binds.nix for Hyprland
cat > "modules/home/hyprland/hosts/$hostname/binds.nix" << 'EOF'
{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in {
  # Host-specific binds for $HOSTNAME
  # These will be merged with the default binds
  bind = [
    # Add host-specific keybinds here
  ];

  bindm = [
    # Add host-specific mouse binds here
  ];
}
EOF

# Replace $HOSTNAME placeholder with actual hostname
sed -i "s/\$HOSTNAME/$hostname/g" "modules/home/hyprland/hosts/$hostname/binds.nix"

# Create windowrules.nix for Hyprland
cat > "modules/home/hyprland/hosts/$hostname/windowrules.nix" << 'EOF'
{host, ...}: let
  inherit
    (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in {
  # Host-specific window rules for $HOSTNAME
  # These will be merged with the default window rules
  windowrule = [
    # Add host-specific window rules here
  ];
}
EOF

# Replace $HOSTNAME placeholder with actual hostname
sed -i "s/\$HOSTNAME/$hostname/g" "modules/home/hyprland/hosts/$hostname/windowrules.nix"

print_success "Hyprland configurations created"

# Create Niri host-specific configuration files
mkdir -p "modules/home/niri/hosts/$hostname"

# Create keybinds.nix for Niri
cat > "modules/home/niri/hosts/$hostname/keybinds.nix" << 'EOF'
{ host, ... }:
''
  // Host-specific keybinds for $HOSTNAME
  // Add your custom keybinds here

  // Example:
  // binds {
  //   Mod+Shift+B { spawn "zen"; }
  // }
''
EOF

sed -i "s/\$HOSTNAME/$hostname/g" "modules/home/niri/hosts/$hostname/keybinds.nix"

# Create outputs.nix for Niri
cat > "modules/home/niri/hosts/$hostname/outputs.nix" << 'EOF'
{ host, ... }:
''
  // Host-specific output configuration for $HOSTNAME
  // Configure your monitors here

  output "eDP-1" {
    mode "1920x1080@60.000"
    scale 1.0
    position x=0 y=0
  }

  // Add more outputs as needed
  // output "HDMI-A-1" {
  //   mode "2560x1440@144.000"
  //   scale 1.0
  //   position x=1920 y=0
  // }
''
EOF

sed -i "s/\$HOSTNAME/$hostname/g" "modules/home/niri/hosts/$hostname/outputs.nix"

# Create windowrules.nix for Niri
cat > "modules/home/niri/hosts/$hostname/windowrules.nix" << 'EOF'
{ host, ... }:
''
  // Host-specific window rules for $HOSTNAME
  // Add your custom window rules here

  // Example:
  // window-rule {
  //   match app-id="^firefox$"
  //   default-column-width { proportion 0.5; }
  // }
''
EOF

sed -i "s/\$HOSTNAME/$hostname/g" "modules/home/niri/hosts/$hostname/windowrules.nix"

print_success "Niri configurations created"
echo ""

# Add new host files to git so flake can see them
git add hosts/"$hostname"/ modules/home/hyprland/hosts/"$hostname"/ modules/home/niri/hosts/"$hostname"/ 2>/dev/null || true

# Update flake.nix
print_header "Updating Flake Configuration"

if grep -q "\"$hostname\"" flake.nix; then
  print_info "Host already exists in flake.nix"
else
  # Add host to flake.nix right after the default host
  # Use awk to insert at the right location (after default host closing brace, before nixosConfigurations closing brace)
  awk -v hostname="$hostname" -v profile="$profile" -v username="$username" '
    /username = "user";/ { in_default = 1 }
    in_default && /^        };$/ {
      print
      print ""
      print "        " hostname " = mkHost {"
      print "          hostname = \"" hostname "\";"
      print "          profile = \"" profile "\";"
      print "          username = \"" username "\";"
      print "        };"
      in_default = 0
      next
    }
    { print }
  ' flake.nix > flake.nix.tmp && mv flake.nix.tmp flake.nix

  print_success "Added $hostname to flake.nix"

  # Add updated flake.nix to git
  git add flake.nix 2>/dev/null || true
fi
echo ""

# Validate flake
print_header "Validating Configuration"
export NIX_CONFIG="experimental-features = nix-command flakes"
if nix flake metadata --no-write-lock-file . >/dev/null 2>&1; then
  print_success "Flake syntax is valid"
else
  print_error "Flake validation failed - please check configuration"
  exit 1
fi
echo ""

# Build configuration
print_header "Building Black Don OS"
echo -e "${YELLOW}This will take 10-20 minutes depending on your hardware...${NC}"
echo ""

read -p "Ready to build? [Y/n]: " build_confirm
if [[ $build_confirm =~ ^[Nn]$ ]]; then
  echo ""
  print_info "You can build manually later with:"
  echo -e "  ${GREEN}sudo nixos-rebuild switch --flake ~/black-don-os#$hostname${NC}"
  exit 0
fi

export NIX_CONFIG="experimental-features = nix-command flakes"

if sudo nixos-rebuild switch --flake .#"$hostname"; then
  echo ""
  print_header "Installation Successful!"
  echo ""
  print_success "Black Don OS has been installed!"
  echo ""
  echo -e "${BLUE}What's next:${NC}"
  echo -e "  1. Your configuration is in: ${GREEN}~/black-don-os/hosts/$hostname/${NC}"
  echo -e "  2. Both Hyprland and Niri are available - select at login screen"
  echo -e "  3. Customize: ${GREEN}~/black-don-os/hosts/$hostname/variables.nix${NC}"
  echo -e "  4. Rebuild: ${GREEN}sudo nixos-rebuild switch --flake ~/black-don-os#$hostname${NC}"
  echo ""
  echo -e "${YELLOW}Tip: Update your monitor settings in variables.nix for optimal display${NC}"
  echo ""
else
  echo ""
  print_error "Build failed"
  echo ""
  echo -e "${YELLOW}To retry manually:${NC}"
  echo -e "  ${GREEN}cd ~/black-don-os${NC}"
  echo -e "  ${GREEN}sudo nixos-rebuild switch --flake .#$hostname${NC}"
  exit 1
fi
