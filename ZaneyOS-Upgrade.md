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

** Converting v2.3 hosts to v2.3 to v2.4

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
  - Ex: `cp -r ~/zaneyos/hosts/default ~/zaneyos/hosts/nixos` ** critical step
    **
  - In the `zaneyos` directory run `git add .`
  - Copy the hardware config file from your backup copy
  - If your hostname is `nixos`
  - Ex: `cp ~/zaneyos-backup/hosts/nixos/hardware.nix`
    ~/zaneyos/hosts/nixos/hardware.nix``
  - Edit the host files to include any of your changes.
    - I.e. monitor settings, username, packages, etc
  - Do NOT copy/restore your old files directly!

```
```
