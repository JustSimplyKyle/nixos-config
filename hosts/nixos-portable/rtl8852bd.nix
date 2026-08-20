{
  config,
  lib,
  pkgs,
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
  boot.extraModulePackages = [ rtl8852bdBtrtl ];

  hardware.firmware = [ rtl8852bdFirmware ];

  boot.extraModprobeConfig = ''
    # This model exposes a broken duplicate platform Bluetooth switch that
    # immediately re-blocks the real RTL8852BD USB controller.
    options ideapad_laptop allow_v4_dytc=1 no_bt_rfkill=1
  '';
}
