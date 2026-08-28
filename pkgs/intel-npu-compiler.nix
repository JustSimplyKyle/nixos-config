{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  onetbb,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-npu-compiler";
  version = "1.35.0";

  src = fetchurl {
    url = "https://github.com/intel/linux-npu-driver/releases/download/v${finalAttrs.version}/linux-npu-driver-v${finalAttrs.version}.20260722-29947505341-ubuntu2404.tar.gz";
    hash = "sha256-OYND5T/axgI60IVu+Iu2ARseEkR6ESvlXoXifvf5bGY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    onetbb
    stdenv.cc.cc.lib
    zlib
    zstd
  ];

  unpackPhase = ''
    runHook preUnpack
    tar -xf "$src"
    dpkg-deb -x intel-driver-compiler-npu_*_amd64.deb source
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib"
    cp -a source/usr/lib/x86_64-linux-gnu/. "$out/lib/"
    runHook postInstall
  '';

  meta = {
    description = "Intel NPU compiler for the Level Zero graph extension";
    homepage = "https://github.com/intel/linux-npu-driver";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
