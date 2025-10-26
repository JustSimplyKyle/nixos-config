{ host, ... }:
''
  // Host-specific keybinds for leno-desktop

  // === Gaming Mode Toggle ===
  Ctrl+Shift+G hotkey-overlay-title="Toggle Gaming Mode" {
      spawn "niri-gaming-mode.sh";
  }
''
