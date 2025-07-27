# 🚀 ZaneyOS Upgrade Procedure

## v2.3 to v2.4

> ℹ️ **Note:**
>
> - This guide applies only to upgrading ZaneyOS from v2.3 to v2.4.
> - Do **NOT** use the `fu` or `fr` aliases for this upgrade.
> - Do **NOT** use the `zcli` utility for this upgrade.

---

### 1. 📝 Prepare for Upgrade

1.  **Ensure your current ZaneyOS is up-to-date:**
    -   Navigate to your ZaneyOS directory:
        ```bash
        cd ~/zaneyos
        ```
    -   If you have any uncommitted changes, commit and push them.
    -   Fetch the latest changes:
        ```bash
        git stash && git fetch && git pull
        ```
    -   Verify that your current host and GPU in `flake.nix` match your system.
        -   You can edit `flake.nix` manually.
        -   Depending on your current build, you might be able to run `zcli update-host`.
    -   If there are any changes, perform a rebuild and reboot:
        -   Use `fr` or `zcli rebuild`.

2.  **Backup your current ZaneyOS directory:**
    ```bash
    mv ~/zaneyos ~/zaneyos-backup
    ```

3.  **Clone the v2.4 branch:**
    ```bash
    git clone https://gitlab.com/zaney/zaneyos.git -b Stable-2.4 --depth=1
    cd ~/zaneyos
    ```

---

### 2. 🔄 Converting v2.3 Hosts to v2.4

ZaneyOS v2.4 introduces new features in the host configuration, giving you more control. This requires a manual update to your host files.

-   **New options in `hosts/hostname/variables.nix`:**

    ```nix
    # Set Display Manager: `tui` for Text, `sddm` for graphical GUI
    # SDDM background is set with stylixImage
    displayManager = "sddm";

    # Enable/disable bundled applications
    tmuxEnable = false;
    alacrittyEnable = false;
    weztermEnable = false;
    ghosttyEnable = false;
    vscodeEnable = false;
    helixEnable = false;
    ```

-   **Migration Steps:**

    1.  **Copy the `default` host template** to a new directory named after your host:
        ```bash
        # Replace YOURHOSTNAME with your actual hostname
        cp -r ~/zaneyos/hosts/default ~/zaneyos/hosts/YOURHOSTNAME
        ```
        *Example:* If your hostname is `nixos`:
        ```bash
        cp -r ~/zaneyos/hosts/default ~/zaneyos/hosts/nixos
        ```

    2.  **Copy the hardware configuration** from your backup:
        ```bash
        # Replace nixos with your hostname if different
        cp ~/zaneyos-backup/hosts/nixos/hardware.nix ~/zaneyos/hosts/nixos/hardware.nix
        ```

    3.  > ❗ **IMPORTANT:** In the `zaneyos` directory, stage your changes:
        >
        > ```bash
        > git add .
        > ```

    4.  **Manually edit your new host files** (`~/zaneyos/hosts/YOURHOSTNAME`) to include any personal customizations (e.g., monitor settings, extra packages).
        > ⚠️ **Warning:** Do **NOT** copy/restore your old host files directly! You must integrate your changes into the new v2.4 file structure.

---

### 3. ✅ Test the Configuration

1.  **Verify `flake.nix`:** Ensure your hostname and GPU type are set correctly.
    -   If you are unsure, run: `zcli update-host`

2.  **Run a configuration check** from the `zaneyos` directory:
    ```bash
    nix flake check
    ```
    -   If there are no errors, you can proceed to the final step.

---

### 4. ⬆️ Running the Upgrade

> ⚠️ **CRITICAL WARNING:**
>
> - Do **NOT** use `fr`, `fu`, or `zcli` for this final upgrade step.
> - Doing so will cause Hyprland to crash when the display manager (greetd or SDDM) restarts during the switch.

1.  **Execute the rebuild command** from the `zaneyos` directory:
    ```bash
    # Replace PROFILE with your GPU (e.g., amd, intel, nvidia, vm)
    sudo nixos-rebuild boot --flake .#PROFILE
    ```

2.  **Reboot your system** once the update is complete.

---

### 🎉 Enjoy! Welcome to ZaneyOS v2.4!
