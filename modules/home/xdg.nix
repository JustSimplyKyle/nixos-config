{pkgs, pkgs-unstable, ...}: {
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
    # Portal configuration moved to system-level (modules/core/flatpak.nix)
    # to avoid package collisions between stable and unstable
  };
}
