{
  description = "Black Don OS (Based on ZaneyOS)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
    flake-utils.url = "github:numtide/flake-utils";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
    helium-browser = {
      url = "github:fpletz/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    let
      system = "x86_64-linux";

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
            zen-browser = inputs.zen-browser.packages.${system}.default;
            helium-browser = inputs.helium-browser.packages.${system}.helium-browser;
          };
          modules = [
            ./profiles/${profile}
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
