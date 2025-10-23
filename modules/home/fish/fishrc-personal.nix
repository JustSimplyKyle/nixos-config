{pkgs, ...}: {
  home.packages = with pkgs; [fish];

  home.file."./.fishrc-personal".text = ''
    # This file allows you to define your own Fish shell customizations
    # Below are examples migrated from zshrc-personal

    # Environment variables
    set -gx CHROME_EXECUTABLE /run/current-system/sw/bin/google-chrome-stable
    set -gx BROWSER "flatpak run app.zen_browser.zen"
    set -gx EDITOR "zeditor"
    # set -gx VISUAL "nvim"

    # Custom aliases can go here
    # alias myalias "my command"

    # Custom functions can go here
    # function my_function
    #   echo "Hello from Fish!"
    # end
  '';
}
