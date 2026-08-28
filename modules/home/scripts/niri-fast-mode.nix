{ pkgs }:

pkgs.writeShellApplication {
  name = "niri-fast-mode";
  runtimeInputs = with pkgs; [
    coreutils
    libnotify
  ];
  text = ''
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/niri"
    enabled="$config_dir/fast.kdl"
    disabled="$config_dir/fast.kdl.disabled"

    exists() {
      [ -e "$1" ] || [ -L "$1" ]
    }

    status() {
      if exists "$enabled" && ! exists "$disabled"; then
        printf 'enabled\n'
        return 0
      fi
      if exists "$disabled" && ! exists "$enabled"; then
        printf 'disabled\n'
        return 1
      fi

      printf 'invalid\n'
      return 2
    }

    case "''${1:-toggle}" in
      status)
        status
        ;;
      toggle)
        if exists "$enabled" && exists "$disabled"; then
          notify-send -u critical "Niri Fast Mode" \
            "Both fast.kdl and fast.kdl.disabled exist; refusing to overwrite either file."
          exit 2
        elif exists "$enabled"; then
          mv -- "$enabled" "$disabled"
          notify-send "Niri Fast Mode Off" "Animations, blur, and opacity restored."
          printf 'disabled\n'
        elif exists "$disabled"; then
          mv -- "$disabled" "$enabled"
          notify-send "Niri Fast Mode On" "Animations, blur, and opacity disabled."
          printf 'enabled\n'
        else
          notify-send -u critical "Niri Fast Mode" \
            "Neither fast.kdl nor fast.kdl.disabled exists. Rebuild Home Manager to initialize it."
          exit 2
        fi
        ;;
      *)
        printf 'usage: niri-fast-mode [toggle|status]\n' >&2
        exit 64
        ;;
    esac
  '';
}
