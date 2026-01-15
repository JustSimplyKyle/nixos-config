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
    { device = "/dev/disk/by-uuid/af996b66-5ec8-4e8f-b8f7-eb1d9c06b4c7";
      fsType = "ext4";
      options = [ "noatime" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F2FA-B193";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "noatime" ];
    };

  fileSystems."/mnt/nvme1" =
    { device = "/dev/disk/by-uuid/42f27e76-7424-45f7-8385-96b4562f7fee";
      fsType = "btrfs";
      options = [ "rw" "relatime" "ssd" "compress=zstd:3" "discard=async" "space_cache=v2" ];
    };

  fileSystems."/mnt/nvme2" =
    { device = "/dev/disk/by-uuid/f816ddbf-3206-90a4-a17a-29b64636594b";
      fsType = "btrfs";
      options = [ "rw" "relatime" "ssd" "compress=zstd:3" "discard=async" "space_cache=v2" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/93daa467-9b2e-413f-81e8-4dcaed069112"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
