{
  profile,
  pkgs,
  lib,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  defaultShell = variables.defaultShell or "zsh";
in
{
  imports = [
    ./zshrc-personal.nix
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "root"
        "line"
      ];
    };
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    oh-my-zsh = {
      enable = true;
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k-config;
        file = "p10k.zsh";
      }
    ];

    initContent = ''
      # Auto-launch Fish if configured as default shell
      ${
        if defaultShell == "fish" then
          ''
            if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]; then
              shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
              exec fish $LOGIN_OPTION
            fi
          ''
        else
          ""
      }

      bindkey "\eh" backward-word
      bindkey "\ej" down-line-or-history
      bindkey "\ek" up-line-or-history
      bindkey "\el" forward-word
      if [ -f $HOME/.zshrc-personal ]; then
        source $HOME/.zshrc-personal
      fi

      # Launch fastfetch on first terminal spawn
      if [[ -z "$FASTFETCH_LAUNCHED" ]]; then
        export FASTFETCH_LAUNCHED=1
        fastfetch
      fi
    '';

    shellAliases = {
      sv = "sudo nvim";
      v = "nvim";
      c = "clear";
      fr = "dcli rebuild";
      fu = "dcli update";
      rebuild = "dcli rebuild";
      update = "dcli update";
      cleanup = "dcli cleanup";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      cat = "bat";
      man = "batman";
      hosts = "dcli list-hosts";
      switch = "dcli switch-host";
    };
  };
}
