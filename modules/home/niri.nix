{pkgs, ...}: {
  # Install Niri and related Wayland utilities
  home.packages = with pkgs; [
    niri
    waybar
    udiskie
    xwayland-satellite
    swww
    # xdg-desktop-portal packages moved to system-level (modules/core/flatpak.nix)
  ];

  # Note: Niri config is managed at ~/.config/niri/config.kdl
  # Remove the xdg.configFile line to allow manual configuration

  # Enable XWayland satellite for X11 app support
  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "Xwayland outside Wayland";
      BindsTo = "graphical-session.target";
      After = "graphical-session.target";
    };
    Service = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      StandardOutput = "journal";
      Restart = "on-failure";
    };
  };
}
