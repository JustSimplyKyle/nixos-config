{ config, lib, pkgs, ... }:

let
  cfg = config.services.batteryRefreshRate;
in
{
  options.services.batteryRefreshRate = {
    enable = lib.mkEnableOption "AC/battery-triggered display refresh rate switcher";

    battery = lib.mkOption {
      type    = lib.types.str;
      default = "BAT1";
      description = "Battery name under /sys/class/power_supply/";
    };

    output = lib.mkOption {
      type    = lib.types.str;
      default = "eDP-1";
      description = "Niri output name to change refresh rate on";
    };

    modeBattery = lib.mkOption {
      type    = lib.types.str;
      default = "2880x1800@60.000";
      description = "Display mode when on battery (unplugged)";
    };

    modeAC = lib.mkOption {
      type    = lib.types.str;
      default = "2880x1800@120.000";
      description = "Display mode when plugged in (AC)";
    };

    pollInterval = lib.mkOption {
      type    = lib.types.ints.positive;
      default = 5; # Reduced default interval since AC changes usually expect a faster response
      description = "Seconds between battery status checks";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.battery-refresh-rate =
      let
        script = pkgs.writeShellApplication {
          name = "battery-refresh-rate";
          runtimeInputs = [ pkgs.niri pkgs.libnotify ];
          text = ''
            BATTERY_PATH="/sys/class/power_supply/${cfg.battery}"
            current_mode="unknown" # Start unknown to force applying correct state on boot

            log() { echo "$(date '+%F %T') $*"; }

            get_status() {
              cat "$BATTERY_PATH/status" 2>/dev/null
            }

            set_mode() {
              local mode="$1"
              if niri msg output "${cfg.output}" mode "$mode" 2>&1; then
                log "Set ${cfg.output} to $mode"
              else
                log "WARNING: niri msg failed – compositor may not be running yet"
              fi
            }

            log "Started (Battery → ${cfg.modeBattery} / AC → ${cfg.modeAC})"

            while true; do
              status=$(get_status)

              if [[ -z "$status" ]]; then
                log "WARNING: could not read battery status, retrying..."
                sleep ${toString cfg.pollInterval}
                continue
              fi

              # Check if discharging (on battery) or anything else (Charging, Full, Not charging -> plugged in)
              if [[ "$status" == "Discharging" ]]; then
                target_mode="battery"
              else
                target_mode="ac"
              fi

              if [[ "$current_mode" != "$target_mode" ]]; then
                if [[ "$target_mode" == "battery" ]]; then
                  log "Unplugged → switching to ${cfg.modeBattery}"
                  notify-send -u normal "Power Saver" \
                    "Unplugged: display is about to be set to ${cfg.modeBattery}" 2>/dev/null || true
                  sleep 5
                  set_mode "${cfg.modeBattery}"
                  current_mode="battery"

                elif [[ "$target_mode" == "ac" ]]; then
                  log "Plugged in → switching to ${cfg.modeAC}"
                  notify-send -u normal "Performance" \
                    "Plugged in: display is about to be restored to ${cfg.modeAC}" 2>/dev/null || true
                  sleep 5
                  set_mode "${cfg.modeAC}"
                  current_mode="ac"
                fi
              fi

              sleep ${toString cfg.pollInterval}
            done
          '';
        };
      in
      {
        Unit = {
          Description = "AC/Battery-triggered display refresh rate switcher (niri / ${cfg.output})";
          After       = [ "graphical-session.target" ];
          PartOf      = [ "graphical-session.target" ];
        };

        Service = {
          Type             = "simple";
          ExecStart        = lib.getExe script;
          Restart          = "on-failure";
          RestartSec       = 10;
          StandardOutput   = "journal";
          StandardError    = "journal";
          SyslogIdentifier = "battery-refresh-rate";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
  };
}
