{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # 1. 'uas' added for high-speed M.2 USB enclosures.
  # 2. 'nvme' kept in case you plug it into a motherboard later.
  # 3. 'ehci_pci' added for booting on older (USB 2.0) hardware.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "usbhid"
    "uas"
  ];

  boot.kernelModules = [ "kvm-intel" ];
  # zram replaces zswap (they shouldn't be combined), so zswap is explicitly disabled
  boot.kernelParams = [
    "zswap.enabled=0"
    # "xe.enable_psr=0"
  ];

  boot.kernel.sysctl = {
    # Flush dirty pages in small steady chunks instead of multi-GB bursts that stall the SSD
    "vm.dirty_bytes" = 268435456; # 256 MB
    "vm.dirty_background_bytes" = 67108864; # 64 MB
    # Swapping to zram is cheap (RAM only), so prefer it over dropping file cache
    "vm.swappiness" = 180;
  };

  # Compressed swap in RAM; the disk swapfile below is only a last resort
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100; # ~3.5:1 zstd ratio, so a full device costs ~9 GB of real RAM
    priority = 100;
  };
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e536b594-3921-4051-b6e6-f58b34bf300c";
    fsType = "btrfs";
    options = [
      "rw"
      "relatime"
      "ssd"
      "compress=zstd:3"
      "discard=async"
      "space_cache=v2"
      "nofail"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BEBC-3223";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
    ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/e536b594-3921-4051-b6e6-f58b34bf300c";
    fsType = "btrfs";
    options = [ "subvol=swap" ];
  };

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "vial-udev-rules";
      text = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="28e9", ATTRS{idProduct}=="3163", MODE="0660", GROUP="users", TAG+="uaccess"
      '';
      destination = "/etc/udev/rules.d/59-vial.rules";
    })
  ];

  # mq-deadline on SSDs so I/O priorities (ionice / ananicy) actually take effect; "none" ignores them
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*|sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  # systemd.services = {
  #   create-swapfile = {
  #     serviceConfig.Type = "oneshot";
  #     wantedBy = [ "swap-swapfile.swap" ];
  #     script = ''
  #       ${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size 32g --uuid clear /swap/swapfile
  #     '';
  #   };
  # };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
      priority = 1;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
