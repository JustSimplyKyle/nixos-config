{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) aiCodeEditorsEnable;
in
{
  config = lib.mkIf aiCodeEditorsEnable {
    nixpkgs.config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "cursor"
        "claude"
      ];

    environment.systemPackages = with pkgs; [
      # AI-powered code editors and development tools
      # code-cursor # AI IDE (currently commented out - uncomment if needed)
      claude-code # Claude AI native development environment
      gemini-cli # Google Gemini CLI tool for terminal AI assistance
    ];
  };
}
