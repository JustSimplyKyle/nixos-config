{pkgs, ...}: {
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
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
  '';
}
