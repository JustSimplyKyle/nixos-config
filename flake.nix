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
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
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
  };

  outputs = {nixpkgs, flake-utils, ...} @ inputs: let
    system = "x86_64-linux";

    # Helper function to create a host configuration
    mkHost = {hostname, profile, username}: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
        host = hostname;
        inherit profile;
        inherit username;
        zen-browser = inputs.zen-browser.packages.${system}.default;
      };
      modules = [./profiles/${profile}];
    };

  in {
    nixosConfigurations = {
      # GPU-based configurations (legacy)
      amd = mkHost { hostname = "nixos-leno"; profile = "amd"; username = "don"; };
      nvidia = mkHost { hostname = "nixos-leno"; profile = "nvidia"; username = "don"; };
      nvidia-laptop = mkHost { hostname = "nixos-leno"; profile = "nvidia-laptop"; username = "don"; };
      intel = mkHost { hostname = "nixos-leno"; profile = "intel"; username = "don"; };
      vm = mkHost { hostname = "nixos-leno"; profile = "vm"; username = "don"; };

      # Host-specific configurations
      nixos-leno = mkHost { hostname = "nixos-leno"; profile = "nvidia-laptop"; username = "don"; };
      leno-desktop = mkHost { hostname = "leno-desktop"; profile = "nvidia"; username = "don"; };
      nix-desktop = mkHost { hostname = "nix-desktop"; profile = "nvidia"; username = "don"; };
      nix-deck = mkHost { hostname = "nix-deck"; profile = "amd"; username = "don"; };
      nix-lab = mkHost { hostname = "nix-lab"; profile = "intel"; username = "don"; };
    };

    # Flutter development environment
    devShells = flake-utils.lib.eachDefaultSystem (system:
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
        default = with pkgs; mkShell rec {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          buildInputs = [
            flutter
            androidSdk
            jdk11
          ];
        };
      });
  };
}
