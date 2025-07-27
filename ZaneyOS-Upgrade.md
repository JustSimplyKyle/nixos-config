<h3>ZaneyOS Upgrade Procedure:</h3>

### v2.3 to v2.4

**Note:

- This only applies to upgrading ZaneyOS v2.3 to v2.4
- Do NOT use the `fu` or `fr` aliases for this upgrade
- Do NOT use `zcli` utility for this upgrade

** Prepare for upgrade

- Insure you are updated to current version of `ZaneyOS`
  - `cd ~/zaneyos`
  - If you have any uncommitted changes, commit and push them
  - `git stash && git fetch && git pull`
  - Make sure current host/gpu matches the `flake.nix`
    - You can edit the `flake.nix`
    - Depending on your current build you can run `zcli update-host`
  - If there are changes, to a rebuild and reboot.
    - Use `fr` or `zcli rebuild`
  - Backup your current `ZaneyOS` directory.
    - `mv ~/Zaneyos ~/Zaneyos-backup`
  - Clone the v2.4 branch
    - `git clone https://gitlab.com/zaney/zaneyos.git -b Stable-2.4 --depth=1`
    - `cd ~/zaneyos`

** Converting v2.3 hosts to v2.4

- `ZaneyOS v2.4` introduces some new features in the hosts file
- You now have more options in the `hosts/hostname/variables.nix`

```nix
# Set Displau Manager # `tui` for Text
login # `sddm` for graphical GUI # SDDM background is set with stylixImage
displayManager = "sddm";

    # Emable/disable bundled applications
    tmuxEnable = false;
    alacrittyEnable = false;
    weztermEnable = false;
    ghosttyEnable = false;
    vscodeEnable = false;
    helixEnable = false;
```

    - Providing more control over your config 
    - However, it also requires manual intervention when upgrading

- Copy the `default` host template, naming it the same as your host
  - `cp -r ~/zaneyos/hosts/default ~/zaneyos/hosts/YOURHOSTNAME`
  - If your current host is `nixos`
  - Ex: `cp -r ~/zaneyos/hosts/default ~/zaneyos/hosts/nixos`
  - Copy the hardware config file from your backup copy
  - Ex: `cp ~/zaneyos-backup/hosts/nixos/hardware.nix`
    ~/zaneyos/hosts/nixos/hardware.nix``
    - IMPORTANT: In the `zaneyos` directory run `git add .`
  - Edit the host files to include any of your changes.
    - I.e. monitor settings, packages, etc
  - Do NOT copy/restore your old files directly!

** Test the configuration

- Make sure you hostname and GPU type are set in `flake.nix`
  - If unsure run `zcli update-host`
- In the `zaneyos` directory run: `nix flake check`
- If there are no errors proceed to next step

** Running the upgrade

## Again do NOT use `fr`, `fu`, or `zcli` for this upgrade!

## If you do, when the rebuild switches Hyprland will crash when either greetd or SDDM restart

- In the `zaneyos` directory run:
  - `sudo nixos-rebuild boot --flake .#PROFILE`
    - Where profile is your GPU
    - I.e. `amd`, `intel`, `nvidia`, `vm`

  - When the update finishes, reboot your system.

  ### Enjoy! Welcome to ZaneyOS v2.4!
