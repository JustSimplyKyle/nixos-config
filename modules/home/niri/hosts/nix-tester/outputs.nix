{ host, ... }:
''
  // Host-specific output configuration for nix-tester
  // Configure your monitors here

  output "eDP-1" {
    mode "1920x1080@60.000"
    scale 1.0
    position x=0 y=0
  }

  // Add more outputs as needed
  // output "HDMI-A-1" {
  //   mode "2560x1440@144.000"
  //   scale 1.0
  //   position x=1920 y=0
  // }
''
