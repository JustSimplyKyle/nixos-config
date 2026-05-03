{
  pkgs,
  lib,
  config,
  inputs,
  host,
  ...
}: let
  scripts = import ./shellApplications.nix { inherit pkgs; };
in
{
  # Add the new custom packages to your environment
  home.packages = with pkgs; [
    bat
    eza 
    zellij
    fd            
    fzf
    gh
    jq
    ripgrep
    wl-clipboard
    zoxide
    inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.oculante
    nix-index
  ] ++ (builtins.attrValues scripts);

  imports = [inputs.zimfw.homeManagerModules.zimfw];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--margin=1"
      "--border=none"
      "--info='hidden'"
      "--header=''"
      "--prompt='--> '"
      "-i"
      "--no-bold"
    ];
  };

  programs.zsh = {
    dotDir = "${config.xdg.configHome}/zsh";
    
    enable = true;
    autosuggestion.enable = false;
    enableCompletion = false;
    autocd = true; 

    syntaxHighlighting = {
      enable = false;
      highlighters = [ "main" "brackets" "pattern" "cursor" "root" "line" ];
    };
    
    historySubstringSearch.enable = false;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
      expireDuplicatesFirst = true;
      share = true;
    };

    zimfw = {
      enable = true;
      degit = true;
      zmodules = [
        "environment"
        "git"
        "input"
        "termtitle"
        "utility"
        "duration-info"
        "git-info"
        "hlissner/zsh-autopair"
        "zsh-users/zsh-completions --fpath src"
        "zsh-users/zsh-autosuggestions"
        "Aloxaf/fzf-tab"
        "archive"
        "completion"
        "zsh-users/zsh-syntax-highlighting"
      ];
    }; 

    envExtra = ''
      setopt no_global_rcs
    '';

    shellAliases = {
      # Navigation & Core
      cat = "bat --plain --paging=never";
      lg = "lazygit";
      
      # Nix/DCLI
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      hosts = "dcli list-hosts";
      switch = "dcli switch-host";
      fr = "dcli rebuild";
      fu = "dcli update";
      rebuild = "dcli rebuild";
      update = "dcli update";
      cleanup = "dcli cleanup";

      # Utils
      niri-kill = "kill \"$(niri msg -j pick-window | jq \".pid\")\"";
      imv = "oculante";
    };

    sessionVariables = {
      EDITOR = "hx";
      PATH = "$PATH:/home/kyle/.local/bin:/home/kyle/.turso";
    };

    initContent = ''
      # Edit command line / Undo / Redo
      autoload -Uz edit-command-line

      autoload -U select-word-style
      select-word-style bash

      zle -N edit-command-line
      bindkey "^xe" edit-command-line
      bindkey '^H'      backward-kill-word            # ctrl+bs    delete previous word
      bindkey '^[[3;5~' kill-word                     # ctrl+del   delete next word
      bindkey "^xl" undo
      bindkey "^xL" redo
      unsetopt nomatch

      # --- ZLE Widgets ---
      # These must remain in Zsh config as they modify the shell state buffer

      fzf-history-search() {
        # --height 12: Only take up 12 lines
        # --border top: Only draw a line at the top
        # --margin 1,0: Slight indentation
        # --info hidden: Hide the counter
        # --tiebreak=begin,index: 
        #     1. 'begin': Prioritize matches starting at the beginning of the line
        #     2. 'index': Sort by order of appearance (which is "Newest" due to fc -rl)
  
        local selected_command=$(fc -rl 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | awk '!seen[$0]++' | \
          fzf --query="^$BUFFER" \
              --height=12 \
              --border=top \
              --info=hidden \
              --prompt="   " \
              --pointer="▶" \
              --tiebreak=begin,index --layout=default \
        )

        if [ -n "$selected_command" ]; then
          BUFFER=`echo -e "$selected_command"`
          CURSOR=$#BUFFER
        fi
        zle reset-prompt
      }

      zle -N fzf-history-search
      bindkey '^[[A' fzf-history-search
      bindkey '^[OA' fzf-history-search  # Up Arrow (Application Mode)
    '';
  };
}
