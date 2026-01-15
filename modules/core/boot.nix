{ pkgs, config, ... }:
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
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "v4l2loopback" ];
    kernelParams = [ "hid_apple.fnmode=2" ] ++ silentBootKernelParams;
    consoleLogLevel = 3;
    initrd.verbose = false;

    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernel.sysctl = { "vm.max_map_count" = 2147483642; };
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
    loader.timeout = 0;
    plymouth = {
      enable = true;
    };
  };
}
