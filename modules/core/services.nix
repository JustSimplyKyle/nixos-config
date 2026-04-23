{profile, ...}: {
  # Services to start
  services = {
    libinput.enable = true; # Input Handling
    fstrim.enable = true; # SSD Optimizer
    gvfs.enable = true; # For Mounting USB & More
    openssh.enable = true; # Enable SSH
    blueman.enable = true; # Bluetooth Support
    tumbler.enable = true; # Image/video preview
    gnome.gnome-keyring.enable = true;
    upower.enable = true; # Power management (required for DMS battery monitoring)

    smartd = {
      enable =
        if profile == "vm"
        then false
        else true;
      autodetect = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]";
          "bluez5.codecs" = "[ sbc sbc_xq aac ldac aptx aptx_hd aptx_ll aptx_ll_duplex ]";
          "bluez5.a2dp.ldac.quality" = "auto";
        };
      };
      wireplumber.enable = true;  # Enable WirePlumber session manager
    };
  };


}
