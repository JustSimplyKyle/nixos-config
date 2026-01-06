{
  pkgs,
  lib,
  config,
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
    nix-index # Replacement for command-not-found
  ];

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
    autosuggestion.enable = true;
    enableCompletion = true;
    autocd = true; 

    syntaxHighlighting = {
      enable = true;
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

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions.src;
      }
      
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab.src;
      }
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair.src;
      }
      {
        # Replaces zim 'extract'
        name = "zsh-extract";
        src = pkgs.fetchFromGitHub {
          owner = "le0me55i";
          repo = "zsh-extract";
          rev = "master";
          sha256 = "sha256-XG9cJuQHAodyd7BrgryC/MiPV1Ch9jK6TvAN+y13uwI=";
        };
      }
      {
        # Replaces zim 'undollar'
        name = "zsh-undollar";
        src = pkgs.fetchFromGitHub {
          owner = "zpm-zsh";
          repo = "undollar";
          rev = "master";
          sha256 = "sha256-VjNiMgGzeTNBbj/xyRc2YKw1NtaflttoSUiIlb/9DJk=";
        };
      }
    ];

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

      # Arch/AUR legacy (from your config)
      aurpush = "makepkg --printsrcinfo >| .SRCINFO;git commit -a --allow-empty; git push";
      shapush = "updpkgsums; makepkg --printsrcinfo >| .SRCINFO; git commit -a --allow-empty; git push";
      
      # Utils
      record = "/home/kyle/record.sh";
      mpv = "env -uMANGOHUD mpv";
      piano = "~/.config/hypr/scripts/piano.sh";
      tb = "nc termbin.com 9999";
      "osu-wayland" = "env SDL_VIDEODRIVER=wayland osu-lazer";
      bg-spawn = "hyprctl dispatch exec";
      niri-kill = "kill \"$(niri msg -j pick-window | jq \".pid\")\"";
    };

    sessionVariables = {
      EDITOR = "hx";
      PATH = "$PATH:/home/kyle/.local/bin:/home/kyle/.turso";
    };

    initContent = ''
      # --- Zim 'input' module logic ---
      bindkey '^H'      backward-kill-word            # ctrl+bs
      bindkey '^[[3;5~' kill-word                     # ctrl+del
      bindkey '^M' accept-line
      bindkey '^]' list-expand
      
      # Edit command line / Undo / Redo
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey "^xe" edit-command-line
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;5C' forward-word
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
          BUFFER="$selected_command"
          CURSOR=$#BUFFER
        fi
        zle reset-prompt
      }

      zle -N fzf-history-search
      bindkey '^[[A' fzf-history-search
      bindkey '^[OA' fzf-history-search  # Up Arrow (Application Mode)

      # Zellij Auto Start
      if [[ -z "$ZELLIJ" ]]; then
         eval "$(zellij setup --generate-auto-start zsh)"
      fi
    '';
  };
}
