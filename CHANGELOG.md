# 📋 ZaneyOS Changelog

> **A comprehensive history of changes, improvements, and updates to ZaneyOS**

---

# 🚀 **Current Release - ZaneyOS v2.3.3**

## ✨ **Post GA Release Notes**

#### 📅 **Updated: August 6th, 2025**

- 📊 **Waybars**: Added new waybars
  - ➕ `waybar-dwm.nix`
  - ➕ `waybar-dwm2.nix`
    - 🎨 Inspired by Matt @TheLinuxCast

- 🔧 **NIX Formatting**: Reformatted NIX to NIX formatting standard

- 🎮 **ZFS Support**: Added `hostID` to `variables.nix` and `network.nix`
  - 💾 This is needed by ZFS
  - 👏 Thanks to Daniel Emeery for the patch

- 📝 **Documentation**: Added `tealdeer.nix (TLDR)` with autoupdate

- 🔧 **ZCLI Fixes**:
  - ➕ Added defensive code to `zcli.nix`
  - 🔍 For rebuilds, updates, hostname and flake host mistches are checked
  - ⚙️ If not same, prompted to auto update the flake.nix
  - 💼 Added `$PROJECT` variable to set repo location
  - 📝 Default is `zaneyos`
  - 📊 Added info on `zcli` utility
  - ⬆️ Updated `zcli` now uses `nh` util to select # of generations to keep
  - ➕ Added `zcli` CLI util. runs rebuild, update, garbage collection and diags
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

- 🔧 **QT Fixes**:
  - 🔄 Update `qt.nix` and `stylix.nix` to `PlatformTheme = "qtct"`
  - ⚠️ In unstable `gnome` is now `adwaita` both cause eval warning
  - ⚙️ Setting it to `qtct` now to prevent this later
  - 🔧 Fixed formatting issue in install script
  - 🔄 Updated flake

- 📝 **NeoVim/NVF Updates**:
  - 📅 `neovim/nvf` update 7/12/25
  - ❌ Disabled programming language spellcheck
  - 🐛 Bug in `nvf` update prompts you to d/l wordlist ever time
  - 🔗 `https://github.com/NotAShelf/nvf/pull/991`
  - ⏳ Waiting for fix 7/12/2025
  - ✅ Re-enabled `css` formatting in `nvf.nix` Thanks `mister_simon` for the fix

- 🤖 **AI Tools**: Added `gemini-cli` AI CLI client only

- 🦇 **Bat/Theme Updates**:
  - 🎨 Set Dracula theme to `bat` command
  - ➕ Added `style = all` and set `man` pager to `bat`

- 🎧 **Audio**: Added `low latecny` setting for `pipewire`

- 📊 **System Monitoring**: Added custom config for `btm` htop like cli util

- 🔧 **Terminal Fixes**:
  - ➕ Added workaround for issue where `ghostty` is slow or hangs
  - ➕ Added electron ozone env variable to `hint`

- 🎥 **OBS Studio**: Added `obs-studio.nix` To allow for customization added common plugins

- 📺 **TMUX**: Updated `tmux.nix` adding popups for lazygit, terminal, edit menu

- 📜 **Install Script**: Improved `install-zaneyos.sh` script Detects GPU and better presentation

- 📝 **Evil Helix**: Added `evil-helix` with language support as option

- 💻 **VSCode Updates**:
  - 🔄 `vscode` update
  - ➕ Added `vscode.nix` with plugins for NIX, BASH, JSON, and VIM keybinds
  - 👏 Thanks to `delciak` for providing the NIX code for `vscode.nix`
  - ➕ Added variable 'enableVscode' in the `hosts/default/variables.nix`
  - 🔄 Updated flake

## 🔧 **Additional Improvements and Fixes**:

- ⚙️ **Variables**: Added vars for `alacritty` `ghostty` `tmux` `wezterm` in `variables.nix`
- 🖥️ **Display Manager**: Added variable `displayManager` in `hosts/hostname/variables.nix`
  - ✨ Set to `sddm` will enable SDDM login manager themed by stylix
  - 💻 Set to `tui` and you get the greetd text login as before
- 🔧 **Scripts**: `hm-find` script wasn't imported so not built
- 📈 **Version**: Updated version to v2.3.3
- 🖥️ **Wayland**: Added `uwsm` package and enabled it in Hyprland
- ⭐ **Starship**: Added alternate `starship` config. `starship-ddubs-1.nix`
- 📚 **Documentation**: Added more info in `hosts/default/variables.nix`
  - 📋 Listing available terminals, stylix images, waybars
  - 📐 Added more info on how to configure monitors
- 🌈 **Colorful Waybar**: Added new waybar from swordlesbian Very colorful and bright
- 🔐 **SDDM**: Added `sddm.nix` themed with stylix - Disabled by default
- 🖼️ **Theming**: Set default stylix image to `mountainscapedark.png`
  - 🎨 Provides warmer colors and super nice SDDM background
- 📝 **Fonts**: Added more fonts to `modules/core/fonts.nix`
- 📱 **Terminal**: Added `alacritty` terminal with `Maple MF` font
- 📦 **Flatpak**: Redid `flatpak.nix` you can add programs and they get updated on rebuilds
- ✅ **Formatter**: Re-enabled `language formatter` had to disable `css` formatter for now
- 🔄 **Updates**: Updated flake
- ❌ **CSS Formatter**: Disabled `language formatter` in `nvf.nix` It fails to build

```text
error: attribute 'prettier' missing
  at /nix/store/3vzc8fxjxvv0b0jrywian6ilb7bdk4y8-source/modules/plugins/languages/css.nix:45:17:
      44|     prettier = {
      45|       package = pkgs.prettier;
        |                 ^
      46|     };
```

- ⏳ **Upstream Fix**: Will re-enable once it's fixed upstream

## 🔀 **Git Enhancements**:

- ➕ **Aliases**: Added three git aliases `com`, `gs`, and `gp`
  - 💬 `git com` will run `git commit -a`
  - 📦 `git gs` will run `git stash`
  - ⬇️ `git gp` will run `git pull`

## 📝 **Editor Improvements**:

- ✅ **Default Editor**: Enabled `neovim` in `packages.nix` to set it to `defaultEditor`
- 🔄 **Relative Numbers**: Restored relative line numbering to nvim `lineNumberMode = "relNumber";`
- ➖ **Cleanup**: Removed extraneous LUA code for diags w/debug messages from `nvf.nix`
- 🔄 **LSP Changes**: NVIM `languages.enableLSP` changed to `vim.settings.lsp.enable`
- 📋 **Clipboard**: Updated `nvf.nix`to use a clipboard provider as "useSystemClipobard" is no longer supported
- 🩺 **Diagnostics**: Restored diagnostic messages inline as errors are detected
- 💾 **Hints**: When you save a file the LSP will show any applicable hints

## 📁 **File Management (EZA)**:

- 🔄 **Organization**: Moved `eza` aliases to `eza.nix`
- 🐚 **Shell Integration**: Enabled bash,zsh, fish integration to `eza`
- 🌍 **Consistency**: All supported shells default `eza` and alias are now set in `eza.nix`
- 🗑️ **Cleanup**: Removed `eza` aliases from `zsh/default.nix` and `bash.nix`
- ⚙️ **Defaults**: Set default options for `eza` in `eza.nix`

## 🔧 **System Fixes & Updates**:

- 🔧 **Git Command**: git command is install script missing `clone` keyword
- ❌ **GPU Fix**: Commented out AQ_DRM_DEVICES ENV variable. Can break config with more than two GPUs
- ✏️ **Docs**: spelling corrections in README.md
- 🔗 **Clone**: Updated clone command in README.md to grab 2.3 stable branch
- 🖥️ **VM Display**: Updated `hyprland.nix` to set VMs `Virtual-1` monitors to 1920x1080@60
- 🔐 **SSH**: Disabled root login for SSH
- 👥 **Access**: Users allowed password SSH access
- 🔀 **Git Features**: Added features and aliases to `git` command

## 🐚 **ZSH Configuration**:

- 🔄 Modified zsh config

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

## 🛠️ **Utility Enhancements**:

- 🎨 **LazyGit**: Added `lazygit.nix` to theme, customize lazygit util
- 🔍 **FZF**: Added `fzf.nix` to customize fzf util
  - 👁️ Added preview to `fzf.nix` Enter to edit
- ➖ **Cleanup**: Removed lazygit from core packages now in lazygit.nix

## 📊 **Waybar & UI Updates**:

- ➕ **Jerry's Waybar**: Added `waybar-ddubs-2.nix` Modified version of Jerry's waybar
- 🎨 **Colors**: Adjusted some colors in Jerry's waybar
- ➕ **Options**: Added Jerry's waybar as option. `Jerry-waybar.nix`
- ✨ **Blur**: Added option to enable blur on waybar on `hyprland.nix` Thx SchotjeChrisman

## 🖥️ **Hyprland Improvements**:

- ✨ **Animations**: Added new Window animation option `animation-moving`from ML4W repo
- 🔧 **Regression Fix**: Fixed regression in `windowrules.nix`
- 🎨 **Stylix**: Stylix was set to unstable - set to 25.05 to stop warning
- ⚙️ **ENV Variables**: Hyprland ENV variables set in two files, created `env.nix`
- 🗑️ **Cleanup**: Hyprland animation files had `inherit`statements that weren't used
- 📐 **Terminal Size**: Pyprland drop down termina size changed from 75% to 70%
- 🚫 **Donations**: Disabled donation messages
- ⚙️ **ANR Threshold**: Set Application Not Responding (ANR) dialog threshold to 20 (def 1)

## 🏗️ **System Architecture**:

- 📌 **Version Pin**: Pinned nixpkgs and homemanager to 25.05 in `flake.nix`
- 🔄 **Lock Update**: Updated `flake.lock`to match changes
- ⬆️ **Hyprland**: Hyprland updated to v0.49
- 🔐 **Lock Fix**: Added `hyprlock.enable=true;` in system packages. This resolves issue with PAM auth errors
- 🔧 **Bug Fixes**: Fixed syntax error in `animations-dynamic.nix`file. Thx Brisingr05
- 🗑️ **Cleanup**: Removed unneeded `home.mgr.enable` in `user.nix` Thx Brisingr05

## 📖 **Documentation & Fixes**:

- ❌ **Disk Module**: Disabled the `df` command in the disk module. Doesn't work w/zaneyos
- 📋 **Monitor Examples**: Added examples for monitor setup in `variables.nix`
- 🔧 **Yazi Fix**: Merged yazi fix for errors after rebuilds. Thank you Daniel
- 🔄 **Flake Update**: Updated flake 05/27/2025
- 📚 **FAQ Updates**: Updated `FAQ.md` with Hyprland Keybinds and how to change waybar
- 📖 **README**: Updated `README` with Hyprland keybinds
- 📜 **Install Script**: Updated install script to pull from the most current release not the main branch
- 🔍 **Backup Files**: Added `hm-find` to find old backup files preventing rebuilds/updates from completing
- 🐛 **Yazi Error**: Added how to fix yazi startup error to `FAQ.md`
- 🎨 **FAQ Format**: Fixed formatting in `FAQ.md` causing yazi info from being hidden

---

# 📚 **Version History**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

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
