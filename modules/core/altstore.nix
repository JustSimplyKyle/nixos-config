{ pkgs, ... } : {
  services.usbmuxd.enable = true;
  services.avahi.enable = true;
  environment.systemPackages = with pkgs; [
    altserver-linux
    libimobiledevice
    bind
  ];
}
