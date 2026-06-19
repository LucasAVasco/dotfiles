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

-- Initialization scripts {{{

hl.on("hyprland.start", function()
	hl.exec_cmd("~/.config/hypr/init.sh")
	hl.exec_cmd("hyprpaper")
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

-- Events and callbacks {{{

---Update the screen temperature of the current workspace.
---@param workspace? HL.Workspace The workspace to update. If nil, the active workspace will be used.
---@param reset? boolean If should reset the temperature before updating it.
local update_workspace_screen_temp = function(workspace, reset)
	if workspace == nil then
		workspace = hl.get_active_workspace()
	end

	if workspace == nil then
		return
	end

	-- Name of the current workspace
	local name = workspace.name
	local index = tonumber(name)
	if index == nil then
		return name
	end
	name = tostring(index % 10)

	-- Run the script that updates the screen temperature
	hl.exec_cmd("~/.config/monitor/update-workspace-screen-temp.sh " .. (reset and "-r " or "") .. name)
end

---Update workspace screen temperature on workspace switch
hl.on("workspace.active", update_workspace_screen_temp)

---Reset workspace screen temperature when the user switches from another tty
hl.on("monitor.layout_changed", function()
	update_workspace_screen_temp(nil, true)
end)

---Update workspace screen temperature when the user switches to another monitor
hl.on("monitor.focused", function()
	update_workspace_screen_temp(nil)
end)

-- }}}

-- Workspaces configuration {{{

---Configure workspaces for a monitor
---@param monitor HL.Monitor
local function configure_workspaces_for_monitor(monitor)
	local current_monitor_index = monitor.id * 10
	for index = 0, 9 do
		current_monitor_index = current_monitor_index + 1
		hl.workspace_rule({
			workspace = tostring(current_monitor_index),
			monitor = monitor.name,
			default = (index == 0),
		})
	end
end

for _, monitor in pairs(hl.get_monitors()) do
	configure_workspaces_for_monitor(monitor)
end

-- Re-run if a new monitor is plugged in
hl.on("monitor.added", function(monitor)
	configure_workspaces_for_monitor(monitor)
end)

-- }}}

require("key_binds")

-- Configures the environment variables for the XDG Desktop Portal. Based in the instructions from ArchWiki
-- (https://wiki.archlinux.org/title/XDG_Desktop_Portal) and Hyprland documentation
-- (https://wiki.hypr.land/Hypr-Ecosystem/xdg-desktop-portal-hyprland/)
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user import-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

	-- Manually start the graphical session (Hyprland does not do this automatically)
	hl.exec_cmd("systemctl --user start manual-graphical-session.target")
end)
