#!/bin/bash
set -euo pipefail

# --- Configuration ---
PROJECT="ddubsos"
PROFILE=""
BACKUP_FILES_STR=""
VERSION="1.0"
FLAKE_NIX_PATH="$HOME/$PROJECT/flake.nix"

# --- Helper Functions ---

print_help() {
  echo "ZaneyOS CLI Utility -- version $VERSION"
  echo ""
  echo "Usage: zcli [command]"
  echo ""
  echo "Commands:"
  echo ""
  echo "  rebuild         - Rebuild the NixOS system configuration."
  echo "  update          - Update the flake and rebuild the system."
  echo "  update-host     - Auto-set host and profile in flake.nix."
  echo ""
  echo "  add-host        - Add a new host configuration."
  echo "  del-host        - Delete a host configuration."
  echo ""
  echo "  list-gens       - List user and system generations."
  echo "  cleanup         - Clean up old system generations."
  echo "  trim            - Trim filesystems to improve SSD performance."
  echo "  diag            - Create a system diagnostic report."
  echo ""
  echo "  help            - Show this help message."
}

# Function to detect the GPU profile
detect_gpu_profile() {
  local detected_profile=""
  if ! command -v lspci &>/dev/null; then
    echo "Warning: lspci command not found. Cannot auto-detect GPU profile." >&2
    return
  fi

  local gpu_info
  gpu_info=$(lspci | grep -i 'vga\|3d')
  local has_nvidia=false
  local has_intel=false
  local has_amd=false
  local has_vm=false

  if echo "$gpu_info" | grep -qi 'nvidia'; then has_nvidia=true; fi
  if echo "$gpu_info" | grep -qi 'amd'; then has_amd=true; fi
  if echo "$gpu_info" | grep -qi 'intel'; then has_intel=true; fi
  if echo "$gpu_info" | grep -qi 'virtio\|vmware'; then has_vm=true; fi

  if $has_vm; then
    detected_profile="vm"
  elif $has_nvidia && $has_intel; then
    detected_profile="nvidia-laptop"
  elif $has_nvidia; then
    detected_profile="nvidia"
  elif $has_amd; then
    detected_profile="amd"
  elif $has_intel; then
    detected_profile="intel"
  fi
  echo "$detected_profile"
}

# Function to update flake.nix with provided or detected values
run_update_host() {
  local target_hostname="$1"
  local target_profile="$2"

  echo "Updating $FLAKE_NIX_PATH..."
  if ! sed -i "s/^[[:space:]]*host[[:space:]]*=.*$/  host = \"$target_hostname\";/" "$FLAKE_NIX_PATH"; then
    echo "Error: Failed to update host in $FLAKE_NIX_PATH" >&2
    return 1
  fi
  if ! sed -i "s/^[[:space:]]*profile[[:space:]]*=.*$/  profile = \"$target_profile\";/" "$FLAKE_NIX_PATH"; then
    echo "Error: Failed to update profile in $FLAKE_NIX_PATH" >&2
    return 1
  fi
  echo "flake.nix updated successfully!"
}

# Function to check if hostname in flake matches current system
check_hostname() {
  local current_hostname
  current_hostname=$(hostname)
  local flake_hostname
  flake_hostname=$(grep "host[[:space:]]*=" "$FLAKE_NIX_PATH" | sed -n 's/.*host[[:space:]]*=[[:space:]]*\"\(.*\)\".*/\1/p')

  if [ "$current_hostname" != "$flake_hostname" ]; then
    echo "Warning: Hostname mismatch detected."
    echo "  System hostname: '$current_hostname'"
    echo "  Flake hostname:  '$flake_hostname'"
    read -p "Do you want to update flake.nix with the current system's hostname and profile? (y/N) " -n 1 -r
    echo
    case "$REPLY" in
      y|Y)
        local detected_profile
        detected_profile=$(detect_gpu_profile)
        if [ -z "$detected_profile" ]; then
          echo "Error: Could not auto-detect GPU profile. Aborting." >&2
          exit 1
        fi
        run_update_host "$current_hostname" "$detected_profile"
        ;;
      *)
        echo "Aborting due to hostname mismatch." >&2
        exit 1
        ;;
    esac
  fi
}

# --- Main Logic ---
main() {
  if [ "$#" -eq 0 ]; then
    print_help
    exit 1
  fi

  local command="$1"
  shift # consume command

  case "$command" in
  rebuild)
    check_hostname
    echo "Starting NixOS rebuild..."
    if sudo nixos-rebuild switch --flake "$HOME/$PROJECT#$PROFILE"; then
      echo "Rebuild finished successfully."
    else
      echo "Error: Rebuild failed." >&2
      exit 1
    fi
    ;;

  update)
    check_hostname
    echo "Updating flake and rebuilding system..."
    if sudo nixos-rebuild switch --upgrade --flake "$HOME/$PROJECT#$PROFILE"; then
      echo "Update and rebuild finished successfully."
    else
      echo "Error: Update and rebuild failed." >&2
      exit 1
    fi
    ;;

  update-host)
    local detected_profile
    detected_profile=$(detect_gpu_profile)
    if [ -z "$detected_profile" ]; then
        echo "Error: Could not auto-detect GPU profile." >&2
        exit 1
    fi
    run_update_host "$(hostname)" "$detected_profile"
    ;;

  add-host)
    # --- Add Host ---
    echo "Which project are you working on? (ddubsos/zaneyos)"
    read -r SELECTED_PROJECT

    if [ "$SELECTED_PROJECT" != "ddubsos" ] && [ "$SELECTED_PROJECT" != "zaneyos" ]; then
        echo "Invalid project name. Please enter either 'ddubsos' or 'zaneyos'."
        exit 1
    fi

    read -p "Enter the new hostname: " new_hostname

    if [ -z "$new_hostname" ]; then
        echo "Hostname cannot be empty."
        exit 1
    fi

    if [ -d "$HOME/$SELECTED_PROJECT/hosts/$new_hostname" ]; then
        echo "Host already exists."
        exit 1
    fi

    echo "Copying default host configuration..."
    cp -r "$HOME/$SELECTED_PROJECT/hosts/default" "$HOME/$SELECTED_PROJECT/hosts/$new_hostname"

    PS3="Please select a GPU type: "
    select opt in "nvidia" "amd" "intel" "vm" "nvidia-laptop"; do
        case $opt in
        "nvidia" | "amd" | "intel" | "vm" | "nvidia-laptop")
            if [ -f "$HOME/$SELECTED_PROJECT/hosts/$new_hostname/default.nix" ]; then
                sed -i "s/profile[[:space:]]*=.*$/  profile = \"$opt\";/" "$HOME/$SELECTED_PROJECT/hosts/$new_hostname/default.nix"
                echo "GPU type set to $opt"
            else
                echo "Warning: '$HOME/$SELECTED_PROJECT/hosts/$new_hostname/default.nix' not found. Cannot set GPU profile."
            fi
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
        esac
    done

    read -p "Do you want to generate the hardware configuration? (y/N) " -n 1 -r
    echo
    case "$REPLY" in
      y|Y)
        echo "Generating hardware configuration..."
        if command -v nixos-generate-config &>/dev/null; then
            nixos-generate-config --show-hardware-config >"$HOME/$SELECTED_PROJECT/hosts/$new_hostname/hardware.nix"
            echo "Hardware configuration generated."
        else
            echo "Error: nixos-generate-config command not found." >&2
        fi
        ;;
    esac
    ;;

  del-host)
    # --- Delete Host ---
    echo "Which project are you working on? (ddubsos/zaneyos)"
    read -r SELECTED_PROJECT

    if [ "$SELECTED_PROJECT" != "ddubsos" ] && [ "$SELECTED_PROJECT" != "zaneyos" ]; then
        echo "Invalid project name. Please enter either 'ddubsos' or 'zaneyos'."
        exit 1
    fi

    read -p "Enter the hostname to delete: " del_hostname

    if [ -z "$del_hostname" ]; then
        echo "Hostname cannot be empty."
        exit 1
    fi

    if [ ! -d "$HOME/$SELECTED_PROJECT/hosts/$del_hostname" ]; then
        echo "Host does not exist."
        exit 1
    fi

    if [ "$del_hostname" == "default" ]; then
        echo "Cannot delete the default host."
        exit 1
    fi

    read -p "Are you sure you want to delete the host '$del_hostname'? This is irreversible. (y/N) " -n 1 -r
    echo
    case "$REPLY" in
      y|Y)
        echo "Deleting host '$del_hostname'..."
        rm -rf "$HOME/$SELECTED_PROJECT/hosts/$del_hostname"
        echo "Host deleted."
        ;;
      *)
        echo "Deletion cancelled."
        ;;
    esac
    ;;

  list-gens)
    echo "--- System Generations ---"
    nix profile history --profile /nix/var/nix/profiles/system
    ;;

  cleanup)
    echo "This will remove old generations of your system."
    read -p "How many generations do you want to keep? (Leave empty to keep all) " keep_count
    if [ -n "$keep_count" ]; then
        sudo nix-collect-garbage --delete-older-than "${keep_count}d"
    else
        echo "Cleanup cancelled."
    fi
    ;;

  trim)
    echo "Trimming filesystems..."
    sudo fstrim -v /
    ;;

  diag)
    echo "Generating system diagnostic report..."
    inxi --full > "$HOME/diag.txt"
    echo "Diagnostic report saved to $HOME/diag.txt"
    ;;

  help | *)
    print_help
    ;;
  esac
}

main "$@"
