{host, ...}: let
  inherit
    (import ../../hosts/${host}/variables.nix)
    alacrittyEnable
    ghosttyEnable
    tmuxEnable
    waybarChoice
    weztermEnable
    vscodeEnable
    helixEnable
    starshipEnable
    ;
in {
  imports =
    [
      ./amfora.nix
      ./bash.nix
      ./bashrc-personal.nix
      ./bat.nix
      ./btop.nix
      ./cava.nix
      ./emoji.nix
      ./eza.nix
      ./fastfetch
      ./fzf.nix
      ./gh.nix
      ./git.nix
      ./gtk.nix
      ./htop.nix
      ./hyprland
      ./kitty.nix
      ./lazygit.nix
      ./nvf.nix
      ./rofi
      ./qt.nix
      ./scripts
      #./starship.nix
      #./starship-ddubs-1.nix
      ./stylix.nix
      ./swappy.nix
      ./swaync.nix
      ./virtmanager.nix
      waybarChoice
      ./wlogout
      ./xdg.nix
      ./yazi
      ./zoxide.nix
    ]
    ++ (lib.optionals starshipEnable [
      ./starship.nix
      ./zsh {inherit starshipEnable;}
    ])
    ++ (lib.optionals (!starshipEnable) [
      ./zsh {inherit starshipEnable;}
    ])
    ++ (
      if helixEnable
      then [./evil-helix.nix]
      else []
    )
    ++ (
      if vscodeEnable
      then [./vscode.nix]
      else []
    )
    ++ (
      if weztermEnable
      then [./wezterm.nix]
      else []
    )
    ++ (
      if ghosttyEnable
      then [./ghostty.nix]
      else []
    )
    ++ (
      if tmuxEnable
      then [./tmux.nix]
      else []
    )
    ++ (
      if alacrittyEnable
      then [./alacritty.nix]
      else []
    );
}
