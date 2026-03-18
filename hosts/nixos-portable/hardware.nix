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
  
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f7b3ea28-bb5f-46a7-8a01-9c09389a4bf8";
      fsType = "btrfs";
      options = [ "rw" "relatime" "ssd" "compress=zstd:3" "discard=async" "space_cache=v2" "nofail" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/BC5E-BB0D";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "noatime" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/93daa467-9b2e-413f-81e8-4dcaed069112"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
