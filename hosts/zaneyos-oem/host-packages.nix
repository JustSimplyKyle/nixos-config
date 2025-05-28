{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #audacity
    #discord
    nodejs
    #obs-studio
    google-chrome
    bottom
    tmux
    dua
    fd
    fzf
    gping
    lunarvim
    luarocks
    mc
    mission-center
    resources
    ncdu
    gdu
    ugrep
    vscode-fhs
    waypaper
  ];
}
