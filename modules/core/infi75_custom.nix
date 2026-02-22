{ inputs, pkgs, ... }: {
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="024f", MODE="0666", TAG+="uaccess"
  '';

  environment.systemPackages = [
    # inputs.infi75-custom.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
