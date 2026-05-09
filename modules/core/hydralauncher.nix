{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    umu-launcher
    hydralauncher
    python3
    wine
  ];
}
