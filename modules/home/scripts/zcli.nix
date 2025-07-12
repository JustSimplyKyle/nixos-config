{
  pkgs,
  profile,
  backupFiles ? [".config/mimeapps.list.backup"],
  ...
}: let
  backupFilesString = pkgs.lib.strings.concatStringsSep " " backupFiles;
in
  pkgs.writeShellScriptBin "zcli" ''
    #!${pkgs.bash}/bin/bash
    set -euo pipefail

    # --- Configuration ---
    PROJECT="zaneyos"
    PROFILE="${profile}"
    BACKUP_FILES_STR="${backupFilesString}"
    VERSION="1.0"
    FLAKE_NIX_PATH="$HOME/$PROJECT/flake.nix"

    # --- Helper Functions ---

    print_help() {
      echo "ZaneyOS CLI Utility -- version $VERSION"
      echo ""
      echo "Usage: zcli [command]"
      echo ""
      echo "Commands:"
      echo "  rebuild         - Rebuild the NixOS system configuration."
      echo "  update          - Update the flake and rebuild the system."
      echo "  update-host     - Auto-set host and profile in flake.nix."
      echo ""
      echo "  list-gens       - List user and system generations."
      echo "  cleanup         - Clean up old system generations."
      echo ""
      echo "  add-host        - Add a new host configuration."
      echo "  del-host        - Delete a host configuration."
      echo ""
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
      flake_hostname=$(grep "host[[:space:]]*=" "$FLAKE_NIX_PATH" | sed -n 's/.*host[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p')

      if [ "$current_hostname" != "$flake_hostname" ]; then
        echo "Warning: Hostname mismatch detected."
        echo "  System hostname: '$current_hostname'"
        echo "  Flake hostname:  '$flake_hostname'"
        read -p "Do you want to update flake.nix with the current system's hostname and profile? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          local detected_profile
          detected_profile=$(detect_gpu_profile)
          if [ -z "$detected_profile" ]; then
            echo "Error: Could not auto-detect GPU profile. Aborting." >&2
            exit 1
          fi
          run_update_host "$current_hostname" "$detected_profile"
        else
          echo "Aborting due to hostname mismatch." >&2
          exit 1
        fi
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
        # Implementation for add-host
        echo "Add-host command is not yet fully implemented in this version."
        ;;

      del-host)
        # Implementation for del-host
        echo "Del-host command is not yet fully implemented in this version."
        ;;

      list-gens)
        echo "--- System Generations ---"
        nix profile history --profile /nix/var/nix/profiles/system
        ;;

      cleanup)
        echo "This will remove old generations of your system."
        read -p "How many generations do you want to keep? (Leave empty to keep all) " keep_count
        if [ -n "$keep_count" ]; then
            sudo nix-collect-garbage --delete-older-than "$keep_count"d
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
  ''
