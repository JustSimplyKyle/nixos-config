# Tmux on ddubsOS — Summary & Cheatsheet

## 🚀 Summary of modules/home/terminals/tmux.nix

- Program
  - tmux enabled; prefix: C-a; key mode: vi; baseIndex: 1; pane-base-index: 1
  - Terminal overrides RGB; terminal set to "wezterm"; shell: zsh
  - Mouse: enabled; 12-hour clock; history-limit: 5000; renumber-windows: on

- Status/UX
  - Status bar at top; passthrough: on; confirmations reduced (kill-pane without prompt)

- Plugins
  - vim-tmux-navigator, sensible, catppuccin

---

## 🗝️ Keybindings Cheatsheet

Navigation
- Prefix h/j/k/l — select-pane Left/Down/Up/Right
- Prefix o — select next pane
- C-Tab — next-window
- C-S-Tab — previous-window
- M-Tab — new-window

Splits
- Prefix | — split-window -h (cwd)
- Prefix \ — split-window -fh (cwd)
- Prefix - — split-window -v (cwd)
- Prefix _ — split-window -fv (cwd)

Resize
- Prefix C-h/C-j/C-k/C-l — resize-pane 15 cols/rows in direction
- Prefix m — toggle zoom (resize-pane -Z)

Windows
- Prefix c — new-window
- Prefix n — next-window
- Prefix p — previous-window (note: config binds 'n' twice; intended p for previous)
- Prefix t — clock-mode
- Prefix q — display-panes
- Prefix u — refresh-client

Session/Reload
- Prefix r — source-file ~/.config/tmux/tmux.conf
- Prefix x — kill-pane (no prompt)

Popups (display-popup)
- Prefix C-y — lazygit (80%x80% at cwd)
- Prefix C-n — prompt for session name; create and switch
- Prefix C-j — switch session via fzf
- Prefix C-r — yazi (90%x90% at cwd)
- Prefix C-z — nvim ~/ddubsos/flake.nix (90%x90%)
- Prefix C-t — zsh (75%x75% at cwd)

Menu (display-menu)
- Prefix d — Dotfiles menu with quick-open entries:
  - f: flake.nix (ddubsOS)
  - c: core packages (ddubsOS)
  - g: global packages (ddubsOS)
  - k: keybinds (Hyprland)
  - w: window rules (Hyprland)
  - z: ZaneyOS flake.nix
  - p: ZaneyOS packages
  - q: Exit

Notes
- Pane/Window indices start at 1.
- Terminal passthrough and RGB enabled for truecolor.

