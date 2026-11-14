{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.zellij ];

  # Layouts are managed declaratively (read-only symlinks, one per file).
  # Other files in layouts/ stay writable, so layouts saved from inside zellij still work.
  xdg.configFile."zellij/layouts/rust.kdl".source = ./layouts/rust.kdl;

  # config.kdl is only seeded when missing; afterwards zellij owns it so
  # changes made via its in-app configuration screen persist across rebuilds.
  home.activation.zellijSeedConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.config/zellij/config.kdl"
    if [ ! -e "$cfg" ]; then
      run mkdir -p "$(dirname "$cfg")"
      run install -m 644 ${./config.kdl} "$cfg"
    fi
  '';
}
