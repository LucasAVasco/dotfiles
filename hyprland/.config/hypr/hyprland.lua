require("defaults")
require("permissions")

---Create a color in RGBA format
---@param r number Value between 0 and 255
---@param g number Value between 0 and 255
---@param b number Value between 0 and 255
---@param a number Value between 0 and 1
---@return string
local function rgba(r, g, b, a)
	return "rgba(" .. r .. "," .. g .. "," .. b .. "," .. a .. ")"
end

--- Initialization scripts {{{

hl.on("hyprland.start", function()
	hl.exec_cmd("~/.config/hypr/init.sh")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("~/.config/hypr/gammastep.sh")
end)

--- }}}

-- Environment variables {{{

hl.env("CUSTOM_DESKTOP_SET_WALLPAPER_COMMAND", "~/.config/hypr/update-wallpaper.sh")
hl.env("CUSTOM_DESKTOP_LOGOUT_COMMAND", "hyprctl dispatch hl.dsp.exit {}")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- }}}

-- Devices {{{

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.config({
	input = {
		kb_layout = os.getenv("XKB_DEFAULT_LAYOUT"),

		touchpad = {
			natural_scroll = true,
		},
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

-- }}}

-- Appearance {{{

hl.config({
	general = {

		gaps_in = 7,
		gaps_out = 15,
		border_size = 3,

		col = {
			active_border = rgba(255, 102, 51, 1.0),
			inactive_border = rgba(119, 119, 119, 1.0),
		},
	},

	cursor = {
		inactive_timeout = 2, -- Hide inactive cursor after timeout (seconds)
	},
})

-- Disables border if there is only one window
hl.window_rule({
	name = "no-border-in-single-window",
	match = { workspace = "w[t1]" },
	border_size = 0,
})

-- }}}

require("key_binds")

-- Arch wiki recommendation to enable screen cast (https://wiki.archlinux.org/title/XDG_Desktop_Portal).
-- hl.on("hyprland.start", function()
--		hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
--		hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
-- end)
-- NOTE(LucasAVasco): My configuration works well without these configurations, but you may need to enable them.
