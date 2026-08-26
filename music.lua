--{{{
--  Conky NextGen Framework
--  Author: István Molnár
--  GitHub: https://github.com/molnari811023/conky-nextgen
--  Description: Modular Conky UI framework (Lua engine + Bash backend)
--}}}

--{{{
--  music.lua — Widget data (generated/edited by sh/designer/main.py)
--  Loaded directly by Conky (lua_load = 'music.lua'). Shows the
--  currently playing track via conky_nowplaying_*() (lua/nowplaying.lua).
--}}}

------------------------------------------------------------
-- Global paths / config (formerly settings.lua)
-- script_dir is music.lua's own directory (the project root)
------------------------------------------------------------
script_dir = debug.getinfo(1, "S").source:match("@?(.*/)") or "./"

package.path = package.path
    .. ";" .. script_dir .. "lua/?.lua"
    .. ";" .. script_dir .. "lua/core/?.lua"
    .. ";" .. script_dir .. "lua/draw/?.lua"
    .. ";" .. script_dir .. "lua/weather/?.lua"
    .. ";" .. script_dir .. "lua/hardware/?.lua"

-- JSON_PATH is always needed (weather, hardware/network, nowplaying data)
JSON_PATH      = script_dir .. "tmp/"

draw = {}

ICON_BASE      = script_dir .. "icons/"
ICON_THEME     = "default"
MOON_ICON_BASE = script_dir .. "icons/moon/"
WIND_ICON_BASE = script_dir .. "icons/wind/"

--{{{
-- THEMES — same palette as the other NextGen widgets, kept identical
-- so music.conf matches the rest of the desktop at a glance.
--}}}
THEMES = {

    theme = {

        palette = {
            bg_dark = "#202326",
            bg_mid = "#292c30",
            bg_light = "#31363c",
            fg = "#fcfcfc",
            fg_dim = "#a1a9b1",
            blue = "#3daee9",
            green = "#27ae60",
            yellow = "#f67400",
            red = "#da4453",
        },

        gradients = {
            text_value = { { 1, "#27ae60", 1 } },
            bar_cpu = { { 1, "#3daee9", 1 } },
            border_subtle = { { 1, "#a1a9b1", 0.6 } },
        },

        defaults = {
            background = {
                bg = { { 1, "#202326", 0.9 } },
                border = { { 1, "#4a4d52", 1 } },
                border_width = 2,
            },
            bar = {
                fg = { { 1, "#3daee9", 1 } },
                bg = { { 1, "#3a3d41", 1 } },
            },
            line = {
                fg = { { 1, "#a1a9b1", 1 } },
            },
            graph = {
                fg = { { 1, "#3daee9", 1 } },
                bg = { { 1, "#3a3d41", 1 } },
                border = { { 1, "#4a4d52", 1 } },
                grid_color = { { 1, "#31363c", 1 } },
            },
            ring = {
                fg = { { 1, "#3daee9", 1 } },
                bg = { { 1, "#3a3d41", 1 } },
            },
            text = {
                color = { { 1, "#fcfcfc", 1 } },
            },
            clock = {
                bg = { { 1, "#31363c", 1 } },
                border = { { 1, "#4a4d52", 1 } },
                tick_color = { { 1, "#a1a9b1", 1 } },
                number_color = { { 1, "#fcfcfc", 1 } },
                hour_color = { { 1, "#fcfcfc", 1 } },
                minute_color = { { 1, "#3daee9", 1 } },
                second_color = { { 1, "#f67400", 1 } },
                center_color = { { 1, "#3daee9", 1 } },
            },
            calendar = {
                color_month = { { 1, "#fcfcfc", 1 } },
                color_weekdays = { { 1, "#a1a9b1", 1 } },
                color_days = { { 1, "#a1a9b1", 1 } },
                color_today = { { 1, "#3daee9", 1 } },
                color_outside = { { 1, "#4a4d52", 1 } },
                color_weeknums = { { 1, "#3daee9", 1 } },
            },
        },
    },
}

DEFAULT_THEME = "theme"
_PADDING = 10

------------------------------------------------------------
-- Now Playing — draw items
-- Data comes from lua/nowplaying.lua (conky_nowplaying_*), already
-- wired into the central loader via require.lua ("EXTRAS" section).
------------------------------------------------------------

local STATUS_SYMBOL = {
    Playing = "\226\150\182",  -- ▶
    Paused  = "\226\143\184",  -- ⏸
    Stopped = "\226\150\160",  -- ■
}

-- true only when a track title is actually available; used to switch
-- between the normal layout and the "nothing playing" fallback text
-- (fail quiet, per the widget-builder convention: never let a missing
-- player crash the draw loop with a nil concat).
local function np_has_track()
    local ok, t = pcall(conky_nowplaying_title)
    return ok and t ~= nil and t ~= ""
end

draw[#draw + 1] = {
    type = "background",
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    radius = 12,
}

-- Album art — only drawn when a track AND art are actually available
draw[#draw + 1] = {
    type = "image",
    x = 10,
    y = 10,
    width = 100,
    height = 100,
    path = function() return conky_nowplaying_art_path() end,
    draw_me = function()
        return np_has_track() and conky_nowplaying_art_path() ~= nil
    end,
}

-- Player + playback status ("▶  spotify")
draw[#draw + 1] = {
    type = "text",
    x = 120,
    y = 12,
    font = "Mono",
    size = 10,
    text = function()
        if not np_has_track() then return "" end
        local status = conky_nowplaying_status() or "Stopped"
        local symbol = STATUS_SYMBOL[status] or STATUS_SYMBOL.Stopped
        local player = conky_nowplaying_player() or ""
        return symbol .. "  " .. player
    end,
    color = { { 1, "#3daee9", 1 } },
}

-- Track title (or the "nothing playing" fallback)
draw[#draw + 1] = {
    type = "text",
    x = 120,
    y = 32,
    font = "Mono",
    size = 13,
    text = function()
        if not np_has_track() then return "Niets aan het afspelen" end
        return conky_nowplaying_title()
    end,
    color = { { 1, "#fcfcfc", 1 } },
}

-- Artist
draw[#draw + 1] = {
    type = "text",
    x = 120,
    y = 54,
    font = "Mono",
    size = 11,
    text = function()
        if not np_has_track() then return "" end
        return conky_nowplaying_artist() or ""
    end,
    color = { { 1, "#a1a9b1", 1 } },
}

-- Album
draw[#draw + 1] = {
    type = "text",
    x = 120,
    y = 72,
    font = "Mono",
    size = 10,
    text = function()
        if not np_has_track() then return "" end
        return conky_nowplaying_album() or ""
    end,
    color = { { 1, "#a1a9b1", 1 } },
}


_GROUPS = {
}

_VIEWS = {
    { name = "main" },
}

------------------------------------------------------------
-- Mouse event actions (only the non-nil ones are listed)
-- All callbacks receive: function(event)
-- event has: type, x, y, x_abs, y_abs, time,
--            button ("left"/"right"/"middle"/"back"/"forward"),
--            direction ("up"/"down"/"left"/"right"),
--            mods = { shift=bool, control=bool, alt=bool, super=bool,
--                     caps_lock=bool, num_lock=bool }
------------------------------------------------------------

_MOUSE_ENABLED = true

MOUSE_CLICK_LEFT = function()
    os.execute("playerctl play-pause &")
end

MOUSE_CLICK_RIGHT = function()
    os.execute("playerctl next &")
end


------------------------------------------------------------
-- Bootstrap (formerly init.lua): load the modules, then
-- initialize the item groups.
------------------------------------------------------------
require("require")
init_groups(_GROUPS)
