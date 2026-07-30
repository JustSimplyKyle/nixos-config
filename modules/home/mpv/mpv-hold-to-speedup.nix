{
  lib,
  writeTextDir,
  mpvScripts,
}:

mpvScripts.buildLua {
  pname = "mpv-hold-to-speedup";
  version = "unstable-2026-07-31";

  src = writeTextDir "hold-to-speedup.lua" ''

    local speed_multiplier = 2.0
    local hold_threshold = 0.5
    local ramp_duration = 0.25
    local ramp_interval = 1 / 60

    local is_speeding = false
    local hold_timer = nil
    local ramp_timer = nil
    local pre_hold_speed = 1.0

    local function stop_ramp()
        if ramp_timer then
            ramp_timer:kill()
            ramp_timer = nil
        end
    end

    -- Fast initially, then gently settles at the target.
    local function ease_out_cubic(t)
        return 1 - (1 - t) ^ 3
    end

    local function speed_on()
        if is_speeding then return end

        is_speeding = true
        pre_hold_speed = mp.get_property_number("speed", 1.0)

        local start_time = mp.get_time()

        stop_ramp()
        ramp_timer = mp.add_periodic_timer(ramp_interval, function()
            local progress = (mp.get_time() - start_time) / ramp_duration

            if progress >= 1 then
                mp.set_property_number("speed", speed_multiplier)
                stop_ramp()
                return
            end

            local eased = ease_out_cubic(progress)
            local new_speed =
                pre_hold_speed +
                (speed_multiplier - pre_hold_speed) * eased

            mp.set_property_number("speed", new_speed)
        end)

        mp.set_osd_ass(
            0,
            0,
            string.format("▶▶ %.1fx faster", speed_multiplier)
        )
    end

    local function speed_off()
        stop_ramp()
        mp.set_property_number("speed", pre_hold_speed)

        is_speeding = false
        mp.set_osd_ass(0, 0, "")
        mp.osd_message("", 0)
        mp.osd_message("▶", 1)
    end

    local function start_hold()
        if hold_timer then
            hold_timer:kill()
        end

        hold_timer = mp.add_timeout(hold_threshold, function()
            hold_timer = nil
            speed_on()
        end)
    end

    local function cancel_hold()
        if hold_timer then
            hold_timer:kill()
            hold_timer = nil
        end
    end

    -- Space: tap pauses, hold temporarily speeds up.
    local function handle_space(event)
        if event.event == "down" then
            start_hold()
        elseif event.event == "up" then
            cancel_hold()

            if is_speeding then
                speed_off()
            else
                mp.command("cycle pause")
            end
        end
    end

    -- Left click: hold temporarily speeds up.
    local function handle_click(event)
        if event.event == "down" then
            start_hold()
        elseif event.event == "up" then
            cancel_hold()

            if is_speeding then
                speed_off()
            end
        end
    end

    mp.add_forced_key_binding(
        "space",
        "speed_space",
        handle_space,
        { complex = true }
    )

    mp.add_forced_key_binding(
        "MBTN_LEFT",
        "speed_click",
        handle_click,
        { complex = true }
    )  '';

  meta = with lib; {
    description = "mpv script that speeds up playback while Space or left-click is held";
    homepage = "https://github.com/iiiGerardoiii/mpv-hold-to-speedup";
    license = licenses.mit;
  };
}
