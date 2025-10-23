{ host, ... }:
''
  // Work around WezTerm's initial configure bug
  window-rule {
      match app-id=r#"^org\.wezfurlong\.wezterm$"#
      default-column-width {}
  }

  // Open the Firefox picture-in-picture player as floating by default
  window-rule {
      match app-id=r#"firefox$"# title="^Picture-in-Picture$"
      open-floating true
  }

  // Global window styling
  window-rule {
      geometry-corner-radius 9
      clip-to-geometry true
      draw-border-with-background false
  }

  // Opacity rules for specific applications
  window-rule {
      match app-id=r#"^(kitty|thunar|org\.telegram\.desktop|discord|vesktop|org\.gnome\.Nautilus|nemo)$"#
      opacity 0.9
  }

  // Launch vesktop and Telegram on DP-3 monitor
  window-rule {
      match app-id=r#"^(vesktop|org\.telegram\.desktop)$"#
      open-on-output "DP-3"
  }

  // OBS always opens at full width on DP-2
  window-rule {
      match app-id=r#"^com\.obsproject\.Studio$"#
      default-column-width { proportion 1.0; }
      open-on-output "DP-2"
  }

  // Zen Browser and Zed settings
  window-rule {
      match app-id=r#"^(zen-beta|dev\.zed\.Zed)$"#
      opacity 0.98
      default-column-width { proportion 0.75; }
  }

  // Web apps and Steam opacity
  window-rule {
      match app-id=r#"^(steam|chrome-app\.restream\.io__home-Default|chrome-claude\.ai__new-Default|chrome-github\.com__-Default|chrome-gitlab\.com__theblackdon_black-don-os-Default|chrome-mail\.proton\.me__u_0_inbox-Default|chrome-meet\.google\.com__-Default|chrome-messages\.google\.com__web_u_1_conversations-Default|chrome-web\.descript\.com__-Default)$"#
      opacity 0.95
  }

  // Commented out: Steam fullscreen rule
  /-window-rule {
      match app-id="steam"
      exclude title="^Steam$"
      open-fullscreen true
  }
''
