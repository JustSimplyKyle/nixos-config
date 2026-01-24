{ pkgs, ... }: {
  repocopy = pkgs.writeShellApplication {
    name = "repocopy";
    runtimeInputs = with pkgs; [ fd parallel wl-clipboard coreutils gnused ];

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
    runtimeInputs = [ pkgs.curl pkgs.coreutils ];
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
    runtimeInputs = with pkgs; [ gnused gnugrep coreutils ];
    text = ''
      # --- Colors ---
      RED='\033[0;31m'
      GREEN='\033[0;32m'
      NC='\033[0m' # No Color

      if [ ! -f "Cargo.toml" ]; then
        echo -e "''${RED}Error: Cargo.toml not found in the current directory.''${NC}"
        exit 1
      fi

      # Finds the line starting with 'name = "..."' and extracts the content inside quotes
      CRATE_NAME=$(grep -E "^name\s*=" Cargo.toml | sed -E 's/name\s*=\s*"([^"]+)"/\1/')

      if [ -z "$CRATE_NAME" ]; then
         echo -e "''${RED}Error: Could not determine package name from Cargo.toml''${NC}"
         exit 1
      fi

      echo -e "''${GREEN}Detected crate: $CRATE_NAME''${NC}"

      cat > flake.nix <<EOF
      {
        description = "$CRATE_NAME";

        inputs = {
          nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          utils.url = "github:numtide/flake-utils";
          rust-overlay.url = "github:oxalica/rust-overlay";
        };

        outputs = { self, nixpkgs, utils, rust-overlay }:
          utils.lib.eachDefaultSystem (system:
            let
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
                pname = "$CRATE_NAME";
                version = "0.1.0";

                src = ./.;

                cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

                nativeBuildInputs = [ pkgs.pkg-config ];
                buildInputs = [ pkgs.openssl ];
              };

              devShells.default = pkgs.mkShell {
                buildInputs = [ 
                  rustToolchain
                  pkgs.cargo 
                  pkgs.rustc 
                  pkgs.rust-analyzer 
                  pkgs.pkg-config
                ];
            
                # Helpful for tools that rely on dynamic linking (like OpenCV)
                # LD_LIBRARY_PATH = "\${pkgs.lib.makeLibraryPath [ pkgs.opencv ]}";
              };
            });
      }
      EOF

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
