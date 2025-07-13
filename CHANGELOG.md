## 🗒️ Changelog

## ZaneyOS v2.3.3 -- Post GA Release Notes

** Updated: July 12th, 2025 **

- Added `tealdeer.nix (TLDR)` with autoupdate
- `zcli` fixes
  - Added defensive code to `zcli.nix`
  - For rebuilds, updates, hostname and flake host mistches are checked
  - If not same, prompted to auto update the flake.nix
  - Added `$PROJECT` variable to set repo location
  - Default is `zaneyos`
  - Added info on `zcli` utility
  - Updated `zcli` now uses `nh` util to select # of generations to keep
  - Added `zcli` CLI util. runs rebuild, update, garbage collection and diags
  ```text
  ❯ zcli
  ```

ZaneyOS CLI Utility -- version 1.0

Usage: zcli [command]

Commands:

rebuild - Rebuild the NixOS system configuration. update - Update the flake and
rebuild the system. update-host - Auto-set host and profile in flake.nix.

add-host - Add a new host configuration. del-host - Delete a host configuration.

list-gens - List user and system generations. cleanup - Clean up old system
generations. trim - Trim filesystems to improve SSD performance. diag - Create a
system diagnostic report.

help - Show this help message.

````
- `qt` fixes
- Update `qt.nix` and `stylix.nix` to `PlatformTheme = "qtct"`
- In unstable `gnome` is now `adwaita` both cause eval warning
- Setting it to `qtct` now to prevent this later
- Fixed formatting issue in install script
- Updated flake
- `neovim/nvf` update 7/12/25
- Disabled programming language spellcheck
- Bug in `nvf` update prompts you to d/l wordlist ever time
- `https://github.com/NotAShelf/nvf/pull/991`
- Waiting for fix 7/12/2025
- Re-enabled `css` formatting in `nvf.nix` Thanks `mister_simon` for the fix
- Added `gemini-cli` AI CLI client only
- Set Dracula theme to `bat` command
- Added `style = all` and set `man` pager to `bat`
- Added `low latecny` setting for `pipewire`
- Added custom config for `btm` htop like cli util
- Added workaround for issue where `ghostty` is slow or hangs
- Added electron ozone env variable to `hint`
- Added `obs-studio.nix` To allow for customization added common plugins
- Updated `tmux.nix` adding popups for lazygit, terminal, edit menu
- Improved `install-zaneyos.sh` script Detects GPU and better presentation
- Added `evil-helix` with language support as option
- `vscode` update
- Added `vscode.nix` with plugins for NIX, BASH, JSON, and VIM keybinds
- Thanks to `delciak` for providing the NIX code for `vscode.nix`
- Added variable 'enableVscode' in the `hosts/default/variables.nix`
- Updated flake
- Added vars for `alacritty` `ghostty` `tmux` `wezterm` in `variables.nix`
- Added variable `displayManager` in `hosts/hostname/variables.nix`
- Set to `sddm` will enable SDDM login manager themed by stylix
- Set to `tui` and you get the greetd text login as before
- `hm-find` script wasn't imported so not built
- Updated version to v2.3.3
- Added `uwsm` package and enabled it in Hyprland
- Added alternate `starship` config. `starship-ddubs-1.nix`
- Added more info in `hosts/default/variables.nix`
- Listing available terminals, stylix images, waybars
- Added more info on how to configure monitors
- Added new waybar from swordlesbian Very colorful and bright
- Added `sddm.nix` themed with stylix - Disabled by default
- Set default stylix image to `mountainscapedark.png`
- Provides warmer colors and super nice SDDM background
- Added more fonts to `modules/core/fonts.nix`
- Added `alacritty` terminal with `Maple MF` font.
- Redid `flatpak.nix` you can add programs and they get updated on rebuilds
- Re-enabled `language formatter` had to disable `css` formatter for now
- Updated Updated flake
- Disabled `language formatter` in `nvf.nix` It fails to build

```text
error: attribute 'prettier' missing
  at /nix/store/3vzc8fxjxvv0b0jrywian6ilb7bdk4y8-source/modules/plugins/languages/css.nix:45:17:
      44|     prettier = {
      45|       package = pkgs.prettier;
        |                 ^
      46|     };
````

- Will re-enable once it's fixed upstream
- Added three git aliases `com`, `gs`, and `gp`
- `git com` will run `git commit -a`
- `git gs` will run `git stash`
- `git gp` will run `git pull`
- Enabled `neovim` in `packages.nix` to set it to `defaultEditor`
- Moved `eza` aliases to `eza.nix`
- Enabled bash,zsh, fish integration to `eza`
- All supported shells default `eza` and alias are now set in `eza.nix`
- Removed `eza` aliases from `zsh/default.nix` and `bash.nix`
- Set default options for `eza` in `eza.nix`
- git command is install script missing `clone` keyword
- Commented out AQ_DRM_DEVICES ENV variable. Can break config with more than two
  GPUs
- spelling corrections in README.md
- Updated clone command in README.md to grab 2.3 stable branch
- Updated `hyprland.nix` to set VMs `Virtual-1` monitors to 1920x1080@60
- Disabled root login for SSH
- Users allowed password SSH access
- Added features and aliases to `git` command
- Added preview to `fzf.nix` Enter to edit
- Removed lazygit from core packages now in lazygit.nix
- Added `eza.nix` to set default options for eza
- Modified zsh config

```nix
 syntaxHighlighting = {
      enable = true;
      highlighters = ["main" "brackets" "pattern" "regexp" "root" "line"];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };
```

- Added `lazygit.nix` to theme, customize lazygit util
- Added `fzf.nix` to customize fzf util
- Added `waybar-ddubs-2.nix` Modified version of Jerry's waybar
- Adjusted some colors in Jerry's waybar
- Disabled the `df` command in the disk module. Doesn't work w/zaneyos
- Added examples for monitor setup in `variables.nix`
- Added Jerry's waybar as option. `Jerry-waybar.nix`
- Added option to enable blur on waybar on `hyprland.nix` Thx SchotjeChrisman
- Added new Window animation option `animation-moving`from ML4W repo
- Restored relative line numbering to nvim `lineNumberMode = "relNumber";`
- Removed extraneous LUA code for diags w/debug messages from `nvf.nix`
- Fixed regression in `windowrules.nix`
- Stylix was set to unstable - set to 25.05 to stop warning
- Hyprland ENV variables set in two files, created `env.nix`
- Hyprland animation files had `inherit`statements that weren't used
- Pyprland drop down termina size changed from 75% to 70%
- Merged yazi fix for errors after rebuilds. Thank you Daniel
- NVIM `languages.enableLSP` changed to `vim.settings.lsp.enable`
- Updated flake 05/27/2025
- Disabled donation messages
- Set Application Not Responding (ANR) dialog threshold to 20 (def 1)
- Restored diagnostic messages inline as errors are detected
- When you save a file the LSP will show any applicable hints
- Updated `nvf.nix`to use a clipboard provider as "useSystemClipobard" is no
  longer supported
- Pinned nixpkgs and homemanager to 25.05 in `flake.nix`
- Updated `flake.lock`to match changes
- Hyprland updated to v0.49
- Added `hyprlock.enable=true;` in system packages. This resolves issue with PAM
  auth errors.
- Fixed syntax error in `animations-dynamic.nix`file. Thx Brisingr05
- Removed unneeded `home.mgr.enable` in `user.nix` Thx Brisingr05
- Updated `FAQ.md` with Hyprland Keybinds and how to change waybar.
- Updated `README` with Hyprland keybinds.
- Updated install script to pull from the most current release not the main
  branch.
- Added `hm-find` to find old backup files preventing rebuilds/updates from
  completing.
- Added how to fix yazi startup error to `FAQ.md`.
- Fixed formatting in `FAQ.md` causing yazi info from being hidden.

<details>

<summary><strong>v2.3 GA Release Notes</strong></summary>

<div style="margin-left: 20px;">

- With this release there are improvements to Neovim
- The entire file structure has been improved.
- Switched from `nixvim` to `nvf` for neovim configuration.
- Improved `bat` config and includes extras now.
- Added profiles for what kind of system you have based of GPU / VM.
- Reduced the host specific files and made the entire flake more modular.
- Fixed git getting set to wrong user settings.
- Fixed hyprlock conflicting with stylix.
- Setup`nh` in a better fashion.
- Added support for `qmk` out of the box.
- Added `usbutils` for lsusb functionality.
- Massive improvement to Hyprland window rules.
- Removed broken support for Apple Silicon (this may return).
- Install script improved.
- Fixed `nix flake check` not working.
- Added nvidia prime PCI ID variables to host `variables.nix`.
- Added vim keybindings zsh (alt+hjkl).
- Added (ctrl+hjkl) keybinds for vim movement while in insert mode in neovim.
- Supports adb out of the box.
- Ddubs/dwilliam62 helped with the addition of pyprland and scratchpad support.
  He is now also a maintainer.
- Can now summon a drop-down terminal with `SUPER, T`.
- Added image used by Stylix into the host variables file.
- Made printing and NFS variables so they can be easily toggled between hosts.
- Added waybar styling choice.
- Kitty, Wezterm, Neovim/nvf, and even Flatpaks all properly themed with Stylix.
- Moved to hyprpolkitagent and fixed qt theming.
- Stylix options that I wanted forced us back on the unstable branch.
- Made Thunar an optional thing, enabled by default. _But for me Yazi is
  enough._

  </div>

  </details>

<br>
<details>
<summary><strong>**ZaneyOS v2.2**</strong> </summary>

<div style="margin-left: 20px;">

- This release has a big theming change
- Move back to rofi. It is a massive improvement in many ways.
- Revert the switch from rofi to wofi. Rofi is just better.
- Switch from Nix Colors to Stylix. It can build colorschemes from a wallpaper.
- Simplified the notification center.
- Improved emoji selection menu and options.
- Adding fine-cmdline plugin for Neovim.
- Removed theme changing scripts as the theme is generated by the image set with
  stylix.image in the config.nix file.
- Starship is now setup in the config.nix file.
- Switched from SDDM to tuigreet and greetd.
- Added Plymouth for better looking booting.
- Improve the fonts being installed and properly separate them from regular
  packages.
- Separated Neovim configuration for readability.
- Updated flake and added fix for popups going to wrkspc 1 in Hyprland.
- Removed a few of the packages that aren't necessary and smartd by default.
- Removed unnecessary Hyprland input in flake as home manager doesn't use it.
- Turned off nfs by default.
- Hyprland plugins are now disabled in the config by default.
- Fastfetch is now replacing neofetch.
- Btop is back baby!
- Switching to Brave as the default to protect user privacy.
- Replaced lsd with eza for a better looking experience.

</div>

</details>
<br>

<details>

<summary><strong>**ZaneyOS v2.1**</strong></summary>

<div style="margin-left: 20px;">

Simple bug fixes.

- Fixed Waybar icons to make them look a bit better.
- Centered the Wofi window always.
- Should have fixed some Steam issues, but I have had some crashes due to Steam
  so be aware of that.
- The flake got an update, so all the packages are fresh.

</div>

</details>

<br>

<details>

<summary><strong>**ZaneyOS v2.0** </strong></summary>

<div style="margin-left: 20px;">

With this new update of ZaneyOS it is a big rewrite of how things are being
done. This update fixes many issues that you guys were facing. As well as makes
things a little easier to understand. You now have a lot being stored inside the
specific host directory, making use of modules, condensing seperate files down,
etc. My hope is that with this update your ability to grasp the flake and expand
it to what you need is much improved. I want to thank everyone for being so
supportive!

- Most configuration put into specific hosts directories for the best
  portability.
- Using modules to condense configuration complexity.
- Simplified options and the complexity around understanding their
  implementation.
- Rewrote the documentation for improved readability.

</div>

</details>
