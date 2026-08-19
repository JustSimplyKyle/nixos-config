{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  # 0bda:b853 with ROM version 3 is the RTL8852BD Bluetooth silicon cut used
  # in RTL8852BE combo cards.  Mainline btrtl's rtl8852bu image has no eco-4
  # patch, and the Windows image needs a different multi-record downloader.
  rtl8852bdSource = pkgs.fetchFromGitHub {
    owner = "mihaits";
    repo = "rtl8852bd-bt-linux";
    rev = "0af62b810c2000c8347fafc30439681b55f85627";
    hash = "sha256-KO4h3d6xfWQZSGPab9ZdbOv5nS3jfdWigVkNwwR2f7M=";
  };

  rtl8852bdFirmware = pkgs.stdenvNoCC.mkDerivation {
    pname = "rtl8852bd-eco4-firmware";
    version = "2026-08-10";
    src = rtl8852bdSource;
    nativeBuildInputs = [ pkgs.python3 ];
    dontBuild = true;
    compressFirmware = false;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/firmware/rtl_bt
      python3 ./extract-firmware.py \
        ${../../rtl8852bd_mp_chip_new.dat} \
        -o $out/lib/firmware/rtl_bt/rtl8852bd_eco4.bin
      runHook postInstall
    '';
    meta.license = lib.licenses.unfree;
  };

  rtl8852bdBtrtl = config.boot.kernelPackages.callPackage (
    { stdenv, kernel }:
    stdenv.mkDerivation {
      pname = "rtl8852bd-btrtl";
      version = "2026-08-10-${kernel.version}";
      src = rtl8852bdSource;
      hardeningDisable = [ "pic" ];
      nativeBuildInputs = kernel.moduleBuildDependencies;
      buildPhase = ''
        runHook preBuild
        make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
          M=$PWD/src LLVM=1 modules
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        install -D src/btrtl.ko \
          $out/lib/modules/${kernel.modDirVersion}/updates/rtl8852bd/btrtl.ko
        runHook postInstall
      '';
      meta = {
        description = "btrtl with RTL8852BD eco-4 firmware download support";
        homepage = "https://github.com/mihaits/rtl8852bd-bt-linux";
        license = lib.licenses.gpl2Only;
        platforms = lib.platforms.linux;
      };
    }
  ) { };
in

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
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=zstd" # compression algorithm
    "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];
  boot.extraModulePackages = [ rtl8852bdBtrtl ];

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
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ rtl8852bdFirmware ];
  boot.extraModprobeConfig = ''
    # This model exposes a broken duplicate platform Bluetooth switch that
    # immediately re-blocks the real RTL8852BU USB controller.
    options ideapad_laptop allow_v4_dytc=1 no_bt_rfkill=1
  '';
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
