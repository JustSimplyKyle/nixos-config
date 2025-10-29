{ host, ... }:
let
  inherit (import ../../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    ;
in
''
  // Host-specific window rules for ${host}
  // Add your custom window rules here

  // Example:
  // window-rule {
  //   match app-id="^firefox$"
  //   default-column-width { proportion 0.5; }
  // }
''
