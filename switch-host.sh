#!/usr/bin/env bash

######################################
# Host Switching Script for Black Don OS
# Author: Black Don
# Quick script to switch between host configurations
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

print_header "Black Don OS - Host Switcher"

# Check if we're in the correct directory
if [[ ! -f "flake.nix" ]] || [[ ! -d "hosts" ]]; then
  print_error "This script must be run from the Black Don OS root directory"
  echo "Please cd to your black-don-os directory and run this script again"
  exit 1
fi

# Get available hosts
hosts=()
for host_dir in hosts/*/; do
  hostname=$(basename "$host_dir")
  if [[ "$hostname" != "default" ]]; then
    hosts+=("$hostname")
  fi
done

if [[ ${#hosts[@]} -eq 0 ]]; then
  print_error "No host configurations found"
  exit 1
fi

# Show current system hostname
current_hostname=$(hostname)
echo -e "Current system hostname: ${GREEN}$current_hostname${NC}"
echo ""

# Show available hosts
echo "Available host configurations:"
for i in "${!hosts[@]}"; do
  host="${hosts[$i]}"
  if [[ "$host" == "$current_hostname" ]]; then
    echo -e "  ${GREEN}$((i+1)). $host (current)${NC}"
  else
    echo -e "  $((i+1)). $host"
  fi
done

echo ""
echo "Commands:"
echo "  b) Build only (no switch)"
echo "  s) Switch immediately"
echo "  t) Test build first, then switch"
echo "  q) Quit"
echo ""

# Get host selection
while true; do
  read -p "Select host number (1-${#hosts[@]}) or command: " choice

  if [[ "$choice" == "q" ]]; then
    echo "Goodbye!"
    exit 0
  fi

  # Check if it's a valid number
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#hosts[@]}" ]]; then
    selected_host="${hosts[$((choice-1))]}"
    break
  elif [[ "$choice" == "b" ]] || [[ "$choice" == "s" ]] || [[ "$choice" == "t" ]]; then
    # Get host for command
    read -p "Select host number (1-${#hosts[@]}): " host_num
    if [[ "$host_num" =~ ^[0-9]+$ ]] && [[ "$host_num" -ge 1 ]] && [[ "$host_num" -le "${#hosts[@]}" ]]; then
      selected_host="${hosts[$((host_num-1))]}"
      command="$choice"
      break
    else
      echo -e "${RED}Invalid host number. Please try again.${NC}"
      continue
    fi
  else
    echo -e "${RED}Invalid selection. Please try again.${NC}"
  fi
done

# Set default command if not specified
if [[ -z "$command" ]]; then
  command="s"  # Default to switch
fi

print_header "Host: $selected_host"

# Show host configuration details
if [[ -f "hosts/$selected_host/variables.nix" ]]; then
  echo "Host configuration preview:"
  echo -e "${BLUE}Browser:${NC} $(grep 'browser =' "hosts/$selected_host/variables.nix" | cut -d'"' -f2)"
  echo -e "${BLUE}Terminal:${NC} $(grep 'terminal =' "hosts/$selected_host/variables.nix" | cut -d'"' -f2)"
  echo -e "${BLUE}GPU Profile:${NC} $(grep -A5 "nixosConfigurations" flake.nix | grep "$selected_host" | sed 's/.*profile = "\([^"]*\)".*/\1/')"
  echo ""
fi

# Execute based on command
case "$command" in
  "b")
    echo -e "${YELLOW}Building configuration for $selected_host...${NC}"
    if nixos-rebuild build --flake ".#$selected_host"; then
      echo -e "${GREEN}✓ Build successful for $selected_host${NC}"
      echo "Configuration is ready but not applied."
      echo "Run 'sudo nixos-rebuild switch --flake .#$selected_host' to apply."
    else
      print_error "Build failed for $selected_host"
      exit 1
    fi
    ;;

  "s")
    echo -e "${YELLOW}Switching to $selected_host configuration...${NC}"
    echo "This will apply the configuration immediately."
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if sudo nixos-rebuild switch --flake ".#$selected_host"; then
        echo -e "${GREEN}✓ Successfully switched to $selected_host configuration${NC}"
        echo "Your system is now running the $selected_host configuration."
        echo "You may need to log out and back in for all changes to take effect."
      else
        print_error "Switch failed for $selected_host"
        exit 1
      fi
    else
      echo "Switch cancelled."
    fi
    ;;

  "t")
    echo -e "${YELLOW}Testing build for $selected_host...${NC}"
    if nixos-rebuild build --flake ".#$selected_host"; then
      echo -e "${GREEN}✓ Build test successful${NC}"
      echo ""
      read -p "Build successful! Switch to this configuration? (y/N): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        if sudo nixos-rebuild switch --flake ".#$selected_host"; then
          echo -e "${GREEN}✓ Successfully switched to $selected_host configuration${NC}"
          echo "Your system is now running the $selected_host configuration."
        else
          print_error "Switch failed for $selected_host"
          exit 1
        fi
      else
        echo "Switch cancelled. Build artifact is available if you want to switch later."
      fi
    else
      print_error "Build test failed for $selected_host"
      exit 1
    fi
    ;;
esac

echo ""
echo -e "${GREEN}Operation completed successfully!${NC}"
