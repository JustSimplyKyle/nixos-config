{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nodejs
    bottom
    tmux
    dua
    fd
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
