{pkgs, ...}: {
  xdg = {
    enable = true;
    configFile."net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text = builtins.toJSON {
      Path = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
    };
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "helium.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/about" = "helium.desktop";
        "application/x-extension-htm" = "helium.desktop";
        "application/x-extension-html" = "helium.desktop";
        "application/x-extension-shtml" = "helium.desktop";
        "application/xhtml+xml" = "helium.desktop";
        "application/x-extension-xhtml" = "helium.desktop";
        "application/x-extension-xht" = "helium.desktop";
        "application/pdf" = "org.gnome.Evince.desktop";
      };
    };
    # Portal configuration moved to system-level (modules/core/flatpak.nix)
    # to avoid package collisions between stable and unstable
  };
}
