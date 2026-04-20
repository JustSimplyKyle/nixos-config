{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libarchive
, openssl
, makeWrapper
, wayland
, libxkbcommon
, xorg
, libGL
, fontconfig
, p7zip
}:

let
  runtimeLibs = [
    wayland
    libxkbcommon
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    fontconfig
  ];

  runtimeBins = [
    p7zip
  ];
in
rustPlatform.buildRustPackage {
  pname = "rust4diva";
  version = "unstable-dc5e3d3";

  src = fetchFromGitHub {
    owner = "R3alCl0ud";
    repo = "Rust4Diva";
    rev = "dc5e3d3";
    hash = "sha256-MXnpsfp8ysM3+AOGsxbGhK1EdOhfLCWztNDkyBd627A=";
  };

  cargoHash = "sha256-ywZ2ElxW55NDwnn2PQwkVOyZPfZWFADFv2QCZmOhdug=";

  nativeBuildInputs = [ 
    pkg-config
    makeWrapper
  ];

  buildInputs = [ 
    libarchive
    openssl
    fontconfig
  ];

  cargoBuildFlags = [ "--all-features" ];

  postInstall = ''
    install -Dm644 assets/rust4diva.png -t $out/share/icons/
    install -Dm644 assets/Rust4Diva.desktop -t $out/share/applications/

    wrapProgram $out/bin/rust4diva \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath runtimeBins}
  '';

  meta = with lib; {
    description = "Project Diva Mod Manager written in rust";
    homepage = "https://github.com/R3alCl0ud/Rust4Diva";
    license = licenses.gpl3Only;
    mainProgram = "rust4diva";
  };
}
