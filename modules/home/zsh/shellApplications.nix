{ pkgs, ... }:
{
  repocopy = pkgs.writeShellApplication {
    name = "repocopy";
    runtimeInputs = with pkgs; [
      fd
      parallel
      wl-clipboard
      coreutils
      gnused
    ];

    excludeShellChecks = [ "SC2016" ];

    text = ''
      # Ignore SC2016: We intentionally use single quotes so 'parallel' handles the expansion
      silent="false"
      realsilent="false"
      args=()

      for arg in "$@"; do
          if [[ "$arg" == "-s" ]]; then silent="true"
          elif [[ "$arg" == "-ss" ]]; then realsilent="true"
          else args+=("$arg"); fi
      done

      export REPOCOPY_SILENT="$silent"
      export REPOCOPY_REAL_SILENT="$realsilent"

      fd -t f -E "*.lock" -E "*.svg" -E "*.png" -E "*.jpg" -E "*.pdf" -0 \
      . "$@" | parallel -0 -k --will-cite '
          if iconv -f utf-8 -t utf-8 "{}" >/dev/null 2>&1; then
              if [ "$REPOCOPY_SILENT" != "true" ] && [ "$REPOCOPY_REAL_SILENT" != "true" ]; then
                  echo -e "\033[0;32m[+] Adding:\033[0m {}" >&2
              fi            
              echo "==> {} <=="; cat "{}"; echo ""
          elif [ "$REPOCOPY_REAL_SILENT" != "true" ]; then
              echo -e "\033[0;33m[-] Skipping (Non-UTF8):\033[0m {}" >&2
          fi
      ' | wl-copy

      [ "$realsilent" != "true" ] && echo "---------------------------------"
      echo "Repository copied to clipboard!"
    '';
  };

  uf = pkgs.writeShellApplication {
    name = "uf";
    runtimeInputs = [
      pkgs.curl
      pkgs.coreutils
    ];
    text = ''
      if [ -z "''${1:-}" ]; then 
        curl -F"file=@-" https://c-v.sh --progress-bar | cat
      else 
        curl -F"file=@$1" https://c-v.sh --progress-bar | cat
      fi
    '';
  };

  cargo-nixify = pkgs.writeShellApplication {
    name = "cargo-nixify";
    runtimeInputs = with pkgs; [
      gnused
      gnugrep
      coreutils
    ];
    text = ''
            # --- Colors ---
            RED='\033[0;31m'
            GREEN='\033[0;32m'
            NC='\033[0m' # No Color

            if [ ! -f "Cargo.toml" ]; then
              echo -e "''${RED}Error: Cargo.toml not found in the current directory.''${NC}"
              exit 1
            fi


      cat > flake.nix <<'FLAKE'
      {
        description = "app";
        inputs = {
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          utils.url = "github:numtide/flake-utils";
          rust-overlay.url = "github:oxalica/rust-overlay";
        };
        outputs = { self, nixpkgs, utils, rust-overlay }:
          utils.lib.eachDefaultSystem (system:
            let
              cargoToml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
              overlays = [ (import rust-overlay) ];
              pkgs = import nixpkgs {
                inherit system overlays;
              };
              rustToolchain = pkgs.rust-bin.stable.latest.default.override {
                extensions = [ "rust-src" "rust-analyzer" ];
              };
            in
            {
              packages.default = pkgs.rustPlatform.buildRustPackage {
                pname = cargoToml.package.name;
                version = cargoToml.package.version;
                src = ./.;
                cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
                nativeBuildInputs = [ pkgs.pkg-config ];
                buildInputs = [ pkgs.openssl ];
              };
              devShells.default = pkgs.mkShell rec {
                buildInputs = [
                  rustToolchain
                  pkgs.cargo
                  pkgs.rustc
                  pkgs.rust-analyzer
                  pkgs.pkg-config
                ];
                LD_LIBRARY_PATH = "$LD_LIBRARY_PATH:''${builtins.toString (pkgs.lib.makeLibraryPath buildInputs)}";
                # LIBCLANG_PATH="''${pkgs.libclang.lib}/lib";

              };
            });
      }
      FLAKE
            echo -e "''${GREEN}Generated flake.nix''${NC}"

            # --- 4. Generate .envrc ---
            if [ ! -f .envrc ]; then
                echo "use flake" > .envrc
                echo -e "''${GREEN}Created .envrc''${NC}"
            elif ! grep -q "use flake" .envrc; then
                echo "use flake" >> .envrc
                echo -e "''${GREEN}Appended 'use flake' to .envrc''${NC}"
            else
                echo -e "''${GREEN}.envrc already exists and is configured.''${NC}"
            fi

            # assumes the directory is made by `cargo`, therefore is git-managed
            git add flake.nix

            # Optional: Automatically allow direnv if installed
            if command -v direnv &> /dev/null; then
                direnv allow
                echo -e "''${GREEN}Direnv allowed.''${NC}"
            fi
    '';
  };
}
