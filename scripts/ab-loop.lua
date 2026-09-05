local state = "none"

local function fmt(t)
    if not t then
        return "?"
    end

    return mp.format_time(t)
end

local function get_loop_a()
    return mp.get_property_number("ab-loop-a")
end

local function get_loop_b()
    return mp.get_property_number("ab-loop-b")
end

local function clear_loop(show_message)
    mp.set_property("ab-loop-a", "no")
    mp.set_property("ab-loop-b", "no")

    state = "none"

    if show_message then
        mp.osd_message("LOOP OFF")
    end
end

local function loop_from_here()
    local pos = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")

    if not pos or not duration then
        mp.osd_message("Cannot set loop")
        return
    end

    local a = get_loop_a()
    local b = get_loop_b()

    if state == "from_here" and a ~= nil and b ~= nil then
        -- Second L: change B from end-of-file to current position
        mp.set_property_number("ab-loop-b", pos)

        mp.osd_message(
            "LOOP  " .. fmt(a) .. " → " .. fmt(pos)
        )

        state = "from_here_closed"

    elseif state == "from_here_closed" and a ~= nil and b ~= nil then
        -- Third L: turn loop off
        clear_loop(true)

    else
        -- First L: current position → end
        mp.set_property_number("ab-loop-a", pos)
        mp.set_property_number("ab-loop-b", duration)

        mp.osd_message(
            "LOOP  " .. fmt(pos) .. " → END"
        )

        state = "from_here"
    end
end

local function loop_to_here()
    local pos = mp.get_property_number("time-pos")

    if not pos then
        mp.osd_message("Cannot set loop")
        return
    end

    local a = get_loop_a()
    local b = get_loop_b()

    if state == "to_here" and a ~= nil and b ~= nil then
        -- Second Alt+L: turn loop off
        clear_loop(true)

    else
        -- First Alt+L: beginning → current position
        mp.set_property_number("ab-loop-a", 0)
        mp.set_property_number("ab-loop-b", pos)

        mp.osd_message(
            "LOOP  00:00 → " .. fmt(pos)
        )

        state = "to_here"
    end
end

-- Reset everything when a new file is loaded.
mp.register_event("file-loaded", function()
    clear_loop(false)
end)

-- These override mpv's normal L binding.
mp.add_forced_key_binding("l", "loop-from-here", loop_from_here)
mp.add_forced_key_binding("ALT+l", "loop-to-here", loop_to_here)

