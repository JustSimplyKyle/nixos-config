{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [pkgs.proton-ge-bin];

      # Enable Steam Input for controller support
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          # Controller support libraries
          libusb1
          udev
          SDL2

          # Additional libraries for better compatibility
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
        ];
      };
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };
}
