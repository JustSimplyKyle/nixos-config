{ host, ... }:
''
  // Monitor configuration for leno-desktop
  // Using the same layout as nix-desktop
  output "DP-1" {
      mode "3440x1440@180.0"
      scale 1.0
      transform "normal"
      position x=2740 y=1455
      variable-refresh-rate
  }

  // Left monitor
  output "DP-2" {
      mode "1920x1080@60.0"
      scale 1.0
      transform "normal"
      position x=820 y=1714
  }

  // Right monitor
  output "DP-3" {
      mode "1920x1080@60.0"
      scale 1.0
      transform "normal"
      position x=6180 y=1714
  }
''
