{pkgs, ...}: {
  xdg.portal = {
    enable = true;
    configPackages = [pkgs.hyprland];
  };
  services = {
    flatpak.enable = true; # Enable Flatpak
  };
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
