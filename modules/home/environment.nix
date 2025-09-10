{pkgs, ...}: {
  home.sessionVariables = {
    CHROME_EXECUTABLE = "$HOME/.local/bin/google-chrome";
    BROWSER = "vivaldi-stable";
  };
}
