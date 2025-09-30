{pkgs, ...}: {
  home.sessionVariables = {
    # CHROME_EXECUTABLE used by Flutter development
    CHROME_EXECUTABLE = "/run/current-system/sw/bin/google-chrome-stable";
    # BROWSER used by CLI tools and applications to open URLs
    BROWSER = "xdg-open";
  };
}
