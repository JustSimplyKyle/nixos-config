# battery-refresh-rate.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.services.batteryRefreshRate;
in
{
  options.services.batteryRefreshRate = {
    enable = lib.mkEnableOption "battery-triggered display refresh rate switcher";

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

    modeLow = lib.mkOption {
      type    = lib.types.str;
      default = "2880x1800@60.000";
      description = "Display mode when battery is low";
    };

    modeHigh = lib.mkOption {
      type    = lib.types.str;
      default = "2880x1800@120.000";
      description = "Display mode when battery is normal";
    };

    thresholdDown = lib.mkOption {
      type    = lib.types.ints.between 1 99;
      default = 30;
      description = "Battery % at or below which to switch to modeLow";
    };

    thresholdUp = lib.mkOption {
      type    = lib.types.ints.between 1 99;
      default = 35;
      description = "Battery % at or above which to restore modeHigh (hysteresis)";
    };

    pollInterval = lib.mkOption {
      type    = lib.types.ints.positive;
      default = 30;
      description = "Seconds between battery checks";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = cfg.thresholdUp > cfg.thresholdDown;
      message   = "services.batteryRefreshRate: thresholdUp must be greater than thresholdDown";
    }];

    systemd.user.services.battery-refresh-rate =
      let
        script = pkgs.writeShellApplication {
          name = "battery-refresh-rate";
          runtimeInputs = [ pkgs.niri pkgs.libnotify ];
          text = ''
            BATTERY_PATH="/sys/class/power_supply/${cfg.battery}"
            current_mode="high"

            log() { echo "$(date '+%F %T') $*"; }

            get_capacity() {
              cat "$BATTERY_PATH/capacity" 2>/dev/null
            }

            set_mode() {
              local mode="$1"
              if niri msg output "${cfg.output}" mode "$mode" 2>&1; then
                log "Set ${cfg.output} to $mode"
              else
                log "WARNING: niri msg failed – compositor may not be running yet"
              fi
            }

            log "Started (↓${toString cfg.thresholdDown}% → ${cfg.modeLow} / ↑${toString cfg.thresholdUp}% → ${cfg.modeHigh})"

            while true; do
              capacity=$(get_capacity)

              if [[ -z "$capacity" ]]; then
                log "WARNING: could not read battery capacity, retrying..."
                sleep ${toString cfg.pollInterval}
                continue
              fi

              if [[ "$current_mode" == "high" && "$capacity" -le ${toString cfg.thresholdDown} ]]; then
                log "Battery ''${capacity}% → switching to ${cfg.modeLow}"
                notify-send -u normal "Power Saver" \
                  "Battery ''${capacity}%: display is about to be set to 60 Hz" 2>/dev/null || true
                sleep 5
                set_mode "${cfg.modeLow}"
                current_mode="low"

              elif [[ "$current_mode" == "low" && "$capacity" -ge ${toString cfg.thresholdUp} ]]; then
                log "Battery ''${capacity}% → switching to ${cfg.modeHigh}"
                notify-send -u normal "Power Saver" \
                  "Battery ''${capacity}%: display is about to be restored to 120 Hz" 2>/dev/null || true
                sleep 5
                set_mode "${cfg.modeHigh}"
                current_mode="high"
              fi

              sleep ${toString cfg.pollInterval}
            done
          '';
        };
      in
      {
        Unit = {
          Description = "Battery-triggered display refresh rate switcher (niri / ${cfg.output})";
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
