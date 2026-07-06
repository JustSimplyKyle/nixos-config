{
  profile,
  pkgs,
  lib,
  ...
}:
{
  systemd.services.factorio.serviceConfig.User = lib.mkForce "kyle";
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
      enable = if profile == "vm" then false else true;
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
      wireplumber.enable = true; # Enable WirePlumber session manager
    };
    # factorio = {
    #   enable = true;
    #   openFirewall = true;
    #   username = "Simplykyle";
    #   token = "86f5f3be1168f6f9266ddf73a271fc";
    #   game-name = "simplykyle's game";
    #   public = true;
    #   # bind = "61.230.232.4";
    #   saveName = "multiplayergame";
    #   game-password = "asdf";
    #   # package = pkgs.factorio-headless.overrideAttrs (old: {
    #   #   installPhase = old.installPhase + ''
    #   #     rm -r $out/share/factorio/data/{elevated-rails,quality,space-age}
    #   #   '';
    #   # });
    #   package = pkgs.runCommand "factorio-steam" { } ''
    #     mkdir -p $out/bin $out/share/factorio
    #     ln -s /home/kyle/.local/share/Steam/steamapps/common/Factorio/bin/x64/factorio $out/bin/factorio
    #     ln -s /home/kyle/.local/share/Steam/steamapps/common/Factorio/data $out/share/factorio/data
    #   '';
    # };
  };

}
