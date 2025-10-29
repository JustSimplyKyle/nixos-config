{ host, ... }:
let
  inherit (import ../../../../hosts/${host}/variables.nix)
    browser
    terminal
    ;
in
''
  // Host-specific keybinds for ${host}
  // Add your custom keybinds here

  // Example:
  // binds {
  //   Mod+Shift+B { spawn "${browser}"; }
  // }
''
