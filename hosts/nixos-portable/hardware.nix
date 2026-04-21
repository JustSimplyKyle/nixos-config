{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # 1. 'uas' added for high-speed M.2 USB enclosures.
  # 2. 'nvme' kept in case you plug it into a motherboard later.
  # 3. 'ehci_pci' added for booting on older (USB 2.0) hardware.
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" "ehci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "usbhid" "uas" 
  ];
  
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ] ++ [
      "zswap.enabled=1" # enables zswap
      "zswap.compressor=zstd" # compression algorithm
      "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
      "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e536b594-3921-4051-b6e6-f58b34bf300c";
      fsType = "btrfs";
      options = [ "rw" "relatime" "ssd" "compress=zstd:3" "discard=async" "space_cache=v2" "nofail" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BEBC-3223";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "noatime" ];
    };

  # fileSystems."/swap" = {
  #   device = "/dev/disk/by-uuid/f7b3ea28-bb5f-46a7-8a01-9c09389a4bf8";
  #   fsType = "btrfs";
  #   options = [ "subvol=swap" ]; 
  # };

  # systemd.services = {
  #   create-swapfile = {
  #     serviceConfig.Type = "oneshot";
  #     wantedBy = [ "swap-swapfile.swap" ];
  #     script = ''
  #       ${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size 32g --uuid clear /swap/swapfile
  #     '';
  #   };
  # };

  # swapDevices =
  #   [ { device = "/swap/swapfile"; size = 32*1024;  }
  #   ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
