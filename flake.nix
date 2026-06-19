{
  description = "Black Don OS (Based on ZaneyOS)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    better-focus.url = "github:justsimplykyle/better-focus";
    infi75-custom.url = "github:justsimplykyle/infi75-custom";
    hxrename.url = "github:justsimplykyle/hxrename";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zimfw.url = "github:joedevivo/zimfw.nix";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
    flake-utils.url = "github:numtide/flake-utils";
    # zen-browser = {
    #   url = "github:0xc000022070/zen-browser-flake";
    #   inputs = {
    #     # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
    #     nixpkgs.follows = "nixpkgs";
    #     home-manager.follows = "home-manager";
    #   };
    # };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant.url = "github:Mic92/direnv-instant";
    jellarr.url = "github:venkyr77/jellarr";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    jellyfin-ultrachromic-src = {
      flake = false;
      owner = "CTalvio";
      repo = "Ultrachromic";
      type = "github";
    };
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wakatime-ls = {
      url = "github:mrnossiom/wakatime-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nixpkgs-stable,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlay_path = ./overlays;
      myOverlays =
        with builtins;
        map (n: import (overlay_path + ("/" + n))) (
          filter (n: match ".*\\.nix" n != null || pathExists (overlay_path + ("/" + n + "/default.nix"))) (
            attrNames (readDir overlay_path)
          )
        );

      nixpkgsConfig = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = false;
      };

      # Helper function to create a host configuration
      mkHost =
        {
          hostname,
          profile,
          username,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            host = hostname;
            inherit profile;
            inherit username;
            helium-browser = inputs.helium.packages.${system}.helium;
          };
          modules = [
            ./profiles/${profile}
            inputs.sops-nix.nixosModules.sops
            inputs.infi75-custom.nixosModules.default

            {
              nixpkgs.overlays = myOverlays;
              nixpkgs.config = nixpkgsConfig;
            }
          ];
        };

    in
    {
      nixosConfigurations = {
        # Default template configuration
        # Users will create their own host configurations during installation
        default = mkHost {
          hostname = "default";
          profile = "amd";
          username = "user";
        };

        nixos-desktop = mkHost {
          hostname = "nixos-desktop";
          profile = "amd";
          username = "kyle";
        };

        nixos-laptop = mkHost {
          hostname = "nixos-laptop";
          profile = "nvidia-laptop-amd";
          username = "kyle";
        };

        nixos-portable = mkHost {
          hostname = "nixos-portable";
          profile = "intel";
          username = "kyle";
        };

        nix-tester = mkHost {
          hostname = "nix-tester";
          profile = "intel";
          username = "don";
        };

        nix-test = mkHost {
          hostname = "nix-test";
          profile = "intel";
          username = "don";
        };
      };

      # Flutter development environment
      devShells = flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };
          };
          buildToolsVersion = "33.0.2";
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [ buildToolsVersion ];
            platformVersions = [ "33" ];
            abiVersions = [ "arm64-v8a" ];
          };
          androidSdk = androidComposition.androidsdk;
        in
        {
          default =
            with pkgs;
            mkShell rec {
              ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
              buildInputs = [
                flutter
                androidSdk
                jdk11
              ];
            };
        }
      );
    };
}
