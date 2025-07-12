{ pkgs, ... }:

pkgs.writeShellScriptBin "zcli" ''
  #!${pkgs.bash}/bin/bash
  /home/dwilliams/zaneyos/modules/home/scripts/zcli.sh "$@"
''
