{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  silentBootKernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];
in
{
  system.etc.overlay.enable = true;

  boot = {
    # kernelPackages = pkgs.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_zen;
    kernelPackages =
      inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;

    kernelModules = [ "v4l2loopback" ];
    kernelParams = [ "hid_apple.fnmode=2" ] ++ silentBootKernelParams;
    consoleLogLevel = 3;
    initrd.verbose = false;
    initrd.systemd.enable = true;

    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 12;
    };
    loader.efi.canTouchEfiVariables = true;
    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
    loader.timeout = lib.mkDefault 0;
    plymouth = {
      enable = true;
    };
  };

  programs.appimage.package = pkgs.appimage-run.override {
    extraPkgs = pkgs: [ pkgs.webkitgtk_4_1 ];
  };
}
