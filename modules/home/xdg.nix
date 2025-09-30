{pkgs, ...}: {
  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "app.zen_browser.zen.desktop";
        "x-scheme-handler/http" = "app.zen_browser.zen.desktop";
        "x-scheme-handler/https" = "app.zen_browser.zen.desktop";
        "x-scheme-handler/about" = "app.zen_browser.zen.desktop";
        "application/x-extension-htm" = "app.zen_browser.zen.desktop";
        "application/x-extension-html" = "app.zen_browser.zen.desktop";
        "application/x-extension-shtml" = "app.zen_browser.zen.desktop";
        "application/xhtml+xml" = "app.zen_browser.zen.desktop";
        "application/x-extension-xhtml" = "app.zen_browser.zen.desktop";
        "application/x-extension-xht" = "app.zen_browser.zen.desktop";
      };
    };
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
      # Explicit portal configuration per desktop environment
      config = {
        # Hyprland uses its own portal + GTK fallback
        hyprland = {
          default = ["hyprland" "gtk"];
        };
        # Niri (Smithay-based) uses wlr portal + GTK fallback
        niri = {
          default = ["wlr" "gtk"];
        };
        # Common fallback for other environments
        common = {
          default = ["gtk"];
        };
      };
    };
  };
}
