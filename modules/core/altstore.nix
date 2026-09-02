{ pkgs, ... } : {
  services.usbmuxd.enable = true;
  services.avahi.enable = false;
  environment.systemPackages = with pkgs; [
    altserver-linux
    libimobiledevice
    bind
  ];
}
