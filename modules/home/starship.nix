# starship is a minimal, fast, and extremely customizable prompt for any shell!
{
  config,
  lib,
  host,
  ...
}:
let
  # accent = "#${config.lib.stylix.colors.base0D}";
  # background-alt = "#${config.lib.stylix.colors.base01}";

  # Import variables to check shell choice
  variables = import ../../hosts/${host}/variables.nix;
  defaultShell = variables.defaultShell or "zsh";
in
{
  programs.starship = {
    # Disable starship for Fish (it has its own custom prompt)
    enable = defaultShell != "fish";
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$nix_shell"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "\n"
        "$character"
      ];

      character = {
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](cyan)";
      };

      nix_shell = {
        format = "[$symbol]($style) ";
        symbol = "🐚";
        style = "";
      };

      git_branch = {
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218)($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        renamed = "";
        deleted = "";
        stashed = "≡";
      };

      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style)) ";
        style = "bright-black";
      };
    };
  };
}
