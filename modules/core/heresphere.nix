{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.heresphere;

  launcher = pkgs.writeShellApplication {
    name = "heresphere";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.umu-launcher
    ];
    text = ''
      install_dir=${lib.escapeShellArg cfg.installDir}
      executable="$install_dir/HereSphere.exe"
      codec_installer=${lib.escapeShellArg cfg.codecInstaller}

      if [[ ! -f "$executable" ]]; then
        echo "HereSphere was not found at $executable" >&2
        echo "Set programs.heresphere.installDir to the directory containing HereSphere.exe." >&2
        exit 1
      fi

      export GAMEID=${lib.escapeShellArg cfg.gameId}
      export STORE=steam
      export PROTONPATH=${lib.escapeShellArg cfg.protonPath}
      export WINEPREFIX="''${HERESPHERE_WINEPREFIX:-$HOME/.local/share/heresphere/prefix}"

      ${lib.optionalString cfg.installCodecs ''
        if [[ ! -f "$codec_installer" ]]; then
          echo "K-Lite Codec Pack was not found at $codec_installer" >&2
          echo "Set programs.heresphere.codecInstaller to the installer path." >&2
          exit 1
        fi

        codec_hash="$(sha256sum "$codec_installer" | cut -d ' ' -f 1)"
        expected_codec_hash=${lib.escapeShellArg cfg.codecInstallerHash}
        codec_marker="$WINEPREFIX/.k-lite-codec-$expected_codec_hash-installed"

        if [[ "$codec_hash" != "$expected_codec_hash" ]]; then
          echo "K-Lite Codec Pack hash mismatch." >&2
          echo "Expected: $expected_codec_hash" >&2
          echo "Actual:   $codec_hash" >&2
          echo "Update programs.heresphere.codecInstallerHash after verifying the installer." >&2
          exit 1
        fi

        if [[ ! -e "$codec_marker" ]]; then
          echo "Installing K-Lite Codec Pack into the HereSphere prefix..."
          umu-run "$codec_installer" ${lib.escapeShellArgs cfg.codecInstallerArgs}
          mkdir -p "$WINEPREFIX"
          touch "$codec_marker"
        fi
      ''}

      exec umu-run "$executable" "$@"
    '';
  };

  desktopEntry = pkgs.makeDesktopItem {
    name = "heresphere";
    desktopName = "HereSphere";
    comment = "VR video player";
    exec = "heresphere %U";
    icon = "video-display";
    categories = [
      "AudioVideo"
      "Video"
    ];
    startupNotify = true;
    terminal = false;
  };
in
{
  options.programs.heresphere = {
    installDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/kyle/motrix-download/heresphere/steamapps/common/HereSphere";
      description = ''
        Runtime path containing HereSphere.exe. This is deliberately a string,
        rather than a Nix path, so the proprietary installation is not copied
        into the Nix store.
      '';
    };

    gameId = lib.mkOption {
      type = lib.types.str;
      default = "1234730";
      description = "Steam application ID passed to umu-launcher.";
    };

    installCodecs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the K-Lite Codec Pack into the HereSphere prefix before first launch.";
    };

    codecInstaller = lib.mkOption {
      type = lib.types.str;
      default = "/home/kyle/motrix-download/K-Lite_Codec_Pack_1985_Standard.exe";
      description = ''
        Runtime path to the K-Lite Codec Pack installer. It remains outside
        the Nix store, like the HereSphere installation itself.
      '';
    };

    codecInstallerHash = lib.mkOption {
      type = lib.types.str;
      default = "97d7e06092f218ce9819bccc03ccb3c6fb0bbe9709924fd6add7177e14065715";
      description = "Expected SHA-256 hash of the external codec installer.";
    };

    codecInstallerArgs = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "/VERYSILENT"
        "/SUPPRESSMSGBOXES"
        "/NORESTART"
        "/SP-"
      ];
      description = "Command-line arguments passed to the K-Lite Codec Pack installer.";
    };

    protonPath = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.proton-ge-bin.steamcompattool}";
      description = "PROTONPATH value passed to umu-launcher.";
    };
  };

  config.environment.systemPackages = [
    launcher
    desktopEntry
  ];
}
