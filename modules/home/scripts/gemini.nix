{pkgs}:
pkgs.writeShellScriptBin "start-gemini" ''

  nix shell --no-write-lock-file github:KenMacD/etc-nixos#"@google/gemini-cli" -c gemini\n

''
