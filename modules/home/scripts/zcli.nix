{ pkgs, ... }:

pkgs.writeShellScriptBin "zcli" ''
  #!${pkgs.bash}/bin/bash
  /home/dwilliams/ddubsos/modules/home/scripts/zcli.sh "$@"
''