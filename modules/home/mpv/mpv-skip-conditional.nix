{
  lib,
  mpvScripts,
  writeTextDir,
}:

mpvScripts.buildLua {
  pname = "mpv-skip-conditional";
  version = "1.0.0";

  src = writeTextDir "skip-conditional.lua" ''
    local MAX_SKIP_TIME = 3.0  -- Max allowed seconds to skip

    local function conditional_skip()
        local sid = mp.get_property_native("sid")
        if not sid then
           local target_time = mp.get_property_number("time-pos") + MAX_SKIP_TIME
           mp.commandv("seek", tostring(target_time), "absolute")
           return
        end

        local old_delay = mp.get_property_number("sub-delay")
        mp.commandv("sub-step", "1")
        local new_delay = mp.get_property_number("sub-delay")
        mp.set_property_number("sub-delay", old_delay)

        local gap = math.abs(new_delay - old_delay)

        if gap < 0.001 then
            mp.osd_message("No upcoming subtitles found.", 2)
            return
        end

        if gap <= MAX_SKIP_TIME then
            mp.commandv("sub-seek", "1")
        else
            mp.osd_message(string.format("Gap is %.1fs (Max %.1fs). Canceled.", gap, MAX_SKIP_TIME), 2)
        end
    end

    local function conditional_rev_skip()
        local sid = mp.get_property_native("sid")
        if not sid then
           local target_time = mp.get_property_number("time-pos") - 3
           mp.commandv("seek", tostring(target_time), "absolute")
           return
        end

        local old_delay = mp.get_property_number("sub-delay")
        mp.commandv("sub-step", "-1")
        local new_delay = mp.get_property_number("sub-delay")
        mp.set_property_number("sub-delay", old_delay)

        local gap = math.abs(new_delay - old_delay)

        if gap < 0.001 then
            mp.osd_message("No upcoming subtitles found.", 2)
            return
        end

        if gap <= 3 then
            mp.commandv("sub-seek", "-1")
        else
            mp.osd_message(string.format("Gap is %.1fs (Max %.1fs). Seeking normaly.", gap, MAX_SKIP_TIME), 2)
           local target_time = mp.get_property_number("time-pos") - 3
           mp.commandv("seek", tostring(target_time), "absolute")
        end
    end

    mp.add_key_binding(nil, "skip-next-conditional", conditional_skip)
    mp.add_key_binding(nil, "skip-prev-conditional", conditional_rev_skip)
  '';

  meta = with lib; {
    description = "mpv script to smoothly skip to the next subtitle if within a specific time gap";
    license = licenses.mit;
  };
}
