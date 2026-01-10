{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
  };
  home.file."./.config/ghostty/config".text = ''
    font-family = Jetbrains Mono
    shell-integration-features = no-cursor,sudo,no-title
    font-size = 14
    cursor-style = block
    mouse-hide-while-typing = true
    mouse-scroll-multiplier = 2

    window-padding-balance = true
    window-save-state = always
    keybind = ctrl+shift+h=new_split:right
    keybind = ctrl+shift+j=new_split:down
    keybind = ctrl+shift+t=new_tab

    keybind = ctrl+h=goto_split:left
    keybind = ctrl+j=goto_split:bottom
    keybind = ctrl+k=goto_split:top
    keybind = ctrl+l=goto_split:right
  '';
}
