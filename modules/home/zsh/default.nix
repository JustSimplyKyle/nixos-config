{
  pkgs,
  lib,
  config,
  inputs,
  host,
  ...
}: let
  accent = "#" + config.lib.stylix.colors.base0D;
  foreground = "#" + config.lib.stylix.colors.base05;
  muted = "#" + config.lib.stylix.colors.base03;
in
{
  # Enable dependencies used in your aliases/functions
  home.packages = with pkgs; [
    bat
    eza 
    zellij
    fd
    fzf
    gh
    jq
    parallel
    ripgrep
    wl-clipboard
    zoxide
    inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.oculante
    nix-index
  ];

  imports = [inputs.zimfw.homeManagerModules.zimfw];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = lib.mkForce {
      "fg+" = accent;
      "bg+" = "-1";
      "fg" = foreground;
      "bg" = "-1";
      "prompt" = muted;
      "pointer" = accent;
    };
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
      # Add the modules you want to use
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
      zle -N edit-command-line
      bindkey "^xe" edit-command-line
      bindkey "^xl" undo
      bindkey "^xL" redo

      # --- Functions ---
      help() {
          "$@" --help 2>&1 | bat --plain --language=help
      }

      uf_gh() { gh gist create "$@" --public; }

      uf() {
        if [ -z $1 ];then curl -F"file=@-" https://c-v.sh --progress-bar | cat
        else curl -F"file=@$1" https://c-v.sh --progress-bar | cat; fi
      }

      function repocopy() {
          local silent="false"
          local realsilent="false"
          local args=()
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
          unset REPOCOPY_SILENT; unset REPOCOPY_REAL_SILENT
      }

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
