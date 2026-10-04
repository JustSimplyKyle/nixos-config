{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

let
  helix-src = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "d79cce4e4bfc24dd204f1b294c899ed73f7e9453";
    hash = "sha256-5IZjbTvP5dNTD8CbEYlNbicdGcbCN9SC9ksMm2ZEXH0=";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "helix-zsh";
  version = "unstable-2025-03-17";

  src = fetchFromGitHub {
    owner = "john-h-k";
    repo = "helix-zsh";
    rev = "0c1948272be4976fbc046fa8dad8493c6039e587";
    hash = "sha256-ZbRUoKqaMfagOZFuj+csdcsV1oAOtf9s6XqRGtOcfmc=";
  };

  cargoRoot = "helix-driver";
  buildAndTestSubdir = cargoRoot;
  cargoHash = "sha256-fS4WEV02FisHKEi6WBeo9FqtCeaIeXjR9/PrDeCtTps=";

  env.HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";

  postPatch = ''
    helixLoader=$(find "$cargoDepsCopy" -mindepth 2 -maxdepth 2 -type d -name 'helix-loader-*' -print -quit)
    helixVendorRoot=$(dirname "$helixLoader")
    cp ${helix-src}/{languages.toml,theme.toml,base16_theme.toml} "$helixVendorRoot"
  '';

  postInstall = ''
    install -Dm644 helix_zsh.zsh "$out/share/helix-zsh/helix_zsh.zsh"
  '';

  meta = {
    description = "Helix keybindings for Zsh";
    homepage = "https://github.com/john-h-k/helix-zsh";
    license = lib.licenses.mit;
    mainProgram = "helix-driver";
    platforms = lib.platforms.unix;
  };
}
