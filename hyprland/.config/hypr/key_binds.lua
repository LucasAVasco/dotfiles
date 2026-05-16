local layout = require("layout")
local SUPER = "SUPER"
local CTRL = "CTRL"
local ALT = "ALT"
local SHIFT = "SHIFT"
local MOUSE_DOWN = "mouse_down"
local MOUSE_UP = "mouse_up"
local MOUSE_LEFT_CLICK = "mouse:272"
local MOUSE_RIGHT_CLICK = "mouse:273"

local OPTS_WITH_REPEAT = { repeating = true }

---Mounts the key bind string from its individual modifiers and key
---@param ... string
---@return string key_bind Key bind definition
local function key(...)
	return table.concat({ ... }, "+")
end

-- Exit {{{

hl.bind(key(SUPER, CTRL, SHIFT, "q"), hl.dsp.exit())
hl.bind(key(SUPER, SHIFT, "x"), hl.dsp.exec_cmd("hyprctl reload"))

-- }}}

-- Applications {{{

hl.bind(key(SUPER, "RETURN"), hl.dsp.exec_cmd("default_term"))
hl.bind(key(SUPER, "f"), hl.dsp.exec_cmd("default_file_manager"))
hl.bind(key(SUPER, "w"), hl.dsp.exec_cmd("~/.local/dotfiles_bin/default_web_browser"))
hl.bind(key(SUPER, "t"), hl.dsp.exec_cmd("~/.config/custom-desktop/chdesk-ui.sh"))
hl.bind(key(SUPER, "a"), hl.dsp.exec_cmd("~/.config/custom-desktop/launcher.sh"))
hl.bind(key(SUPER, "o"), hl.dsp.exec_cmd("~/.config/custom-desktop/org-menu.sh"))
hl.bind(key(SUPER, "r"), hl.dsp.exec_cmd("~/.local/dotfiles_bin/custom-script-popup"))
hl.bind(key(SUPER, SHIFT, "p"), hl.dsp.exec_cmd("~/.config/custom-desktop/password-manager.sh"))
hl.bind(key(SUPER, "s"), hl.dsp.exec_cmd("~/.config/screenshot/take.sh -o /dev/null -c"))
hl.bind(key(SUPER, SHIFT, "s"), hl.dsp.exec_cmd("~/.config/screenshot/take.sh -o /dev/null -i -c"))
hl.bind(key(SUPER, SHIFT, "ESCAPE"), hl.dsp.exec_cmd("~/.config/custom-desktop/session-manager.sh"))

-- }}}

-- Close window {{{

hl.bind(key(SUPER, "c"), hl.dsp.window.close())
hl.bind(key(SUPER, "Delete"), hl.dsp.exec_cmd("hyprctl kill"))

-- }}}

-- Directions {{{

---Maps a key bind to its direction to be used with the focus dispatcher
local directions = {
	["left"] = "left",
	["down"] = "down",
	["up"] = "up",
	["right"] = "right",
	["h"] = "left",
	["j"] = "down",
	["k"] = "up",
	["l"] = "right",
}

---Converts a key bind to the layout cycle dispatcher (used with the monocle layout)
local cycle_layout = {
	["down"] = "cycleprev",
	["left"] = "cycleprev",
	["up"] = "cyclenext",
	["right"] = "cyclenext",
}

---Maps a key bind to its resize width (used to resize the current window)
local resize_width = {
	["left"] = -20,
	["right"] = 20,
}

---Maps a key bind to its resize height (used to resize the current window)
local resize_height = {
	["up"] = -20,
	["down"] = 20,
}

---Focus to direction
---@param direction "left" | "right" | "up" | "down"
local function focus(direction)
	-- The "monocle" layout does not support the focus dispatcher, need to cycle instead
	if layout.get_current() == "monocle" then
		hl.dispatch(hl.dsp.layout(cycle_layout[direction]))
		return
	end

	hl.dispatch(hl.dsp.focus({ direction = direction }))
end

---Generate focus dispatcher
---@param direction "left" | "right" | "up" | "down"
---@return function
local function dsp_focus(direction)
	return function()
		focus(direction)
	end
end

for key_bind, direction in pairs(directions) do
	hl.bind(key(SUPER, key_bind), dsp_focus(direction)) -- Focus to direction
	hl.bind(key(SUPER, ALT, key_bind), hl.dsp.window.move({ direction = direction })) -- Move window to direction

	local x = resize_width[direction] or 0
	local y = resize_height[direction] or 0
	hl.bind(key(SUPER, SHIFT, key_bind), hl.dsp.window.resize({ x = x, y = y, relative = true }), OPTS_WITH_REPEAT) -- Resize in direction
end

-- }}}

-- Workspaces {{{
local workspaces = {
	["r~1"] = "1",
	["r~2"] = "2",
	["r~3"] = "3",
	["r~4"] = "4",
	["r~5"] = "5",
	["r~6"] = "F1",
	["r~7"] = "F2",
	["r~8"] = "F3",
	["r~9"] = "F4",
	["r~10"] = "F5",
	["m-1"] = "BracketLeft",
	["m+1"] = "BracketRight",
	["previous"] = "Backspace",
}

for name, key_bind in pairs(workspaces) do
	hl.bind(key(SUPER, key_bind), hl.dsp.focus({ workspace = name })) -- Focus to work space
	hl.bind(key(SUPER, ALT, key_bind), hl.dsp.window.move({ workspace = name })) -- Move window to work space

	-- Move window to work space but continue in the current one
	hl.bind(key(SUPER, SHIFT, key_bind), hl.dsp.window.move({ workspace = name, follow = false }))
end

-- Magic workspace {{{

---Move current window to special workspace
---@param follow boolean Follow current window or continue in the current workspace
local function move_to_special_workspace(follow)
	local window = hl.get_active_window()
	if window == nil then
		return
	end

	local workspace
	if window.workspace.name == "special:magic" then
		workspace = "r+0" -- Current non-special workspace in the current monitor
	else
		workspace = "special:magic"
	end

	hl.dispatch(hl.dsp.window.move({ workspace = workspace, follow = follow }))
end

hl.bind(key(SUPER, "Tab"), hl.dsp.workspace.toggle_special("magic"))
hl.bind(key(SUPER, ALT, "Tab"), function()
	move_to_special_workspace(true)
end)
hl.bind(key(SUPER, SHIFT, "Tab"), function()
	move_to_special_workspace(false)
end)

-- }}}

-- }}}

-- Node management {{{

hl.bind(key(SUPER, "0"), hl.dsp.window.float({ action = "toogle" }))
hl.bind(key(SUPER, "9"), function()
	hl.dispatch(hl.dsp.window.float({ action = "enable" }))
	hl.dispatch(hl.dsp.window.pin({ action = "enable" }))
end) -- Float and pin
hl.bind(key(SUPER, "8"), hl.dsp.window.fullscreen())
hl.bind(key(SUPER, "7"), hl.dsp.window.pseudo())
hl.bind(key(SUPER, "6"), hl.dsp.layout("togglesplit"))

-- Change layout
hl.bind(key(SUPER, "m"), function()
	layout.next()
end)
hl.bind(key(SUPER, SHIFT, "m"), function()
	layout.previous()
end)

-- }}}

-- Notifications {{{

hl.bind(key(SUPER, SHIFT, "n"), hl.dsp.exec_cmd("~/.config/custom-desktop/dismiss-notifications.sh"))

-- }}}

-- Clipboard {{{

hl.bind(key(SUPER, "y"), hl.dsp.exec_cmd("~/.local/dotfiles_bin/receive-clip-from-sync-folder"))
hl.bind(key(SUPER, "p"), hl.dsp.exec_cmd("~/.local/dotfiles_bin/send-clip-to-sync-folder"))
hl.bind(key(SUPER, SHIFT, "y"), hl.dsp.exec_cmd("~/.config/clipboard/clear.sh"))

-- }}}

-- Screen locker {{{

hl.bind(key(SUPER, "z"), hl.dsp.exec_cmd("~/.config/screenlocker/manager.sh toggle"))
hl.bind(key(CTRL, ALT, "l"), hl.dsp.exec_cmd("~/.config/screenlocker/manager.sh run"))

-- }}}

-- Back light {{{

hl.bind(key(SUPER, "F6"), hl.dsp.exec_cmd("backlight set -5%"))
hl.bind(key(SUPER, "F8"), hl.dsp.exec_cmd("backlight set +5%"))
hl.bind(key(SUPER, "F7"), hl.dsp.exec_cmd("backlight set 20%"))

-- }}}

-- Sound and volume {{{

hl.bind(key(SUPER, "F9"), hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind(key(SUPER, "F10"), hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind(key(SUPER, "F11"), hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind(key(SUPER, "b"), hl.dsp.exec_cmd("~/.config/keyboard/sound_emulator.sh toggle"))

-- }}}

-- Mouse settings {{{

-- Move through workspaces with mouse scroll
hl.bind(key(SUPER, MOUSE_DOWN), hl.dsp.focus({ workspace = "m+1" }))
hl.bind(key(SUPER, MOUSE_UP), hl.dsp.focus({ workspace = "m-1" }))

-- Move window with SUPER + left click
hl.bind(key(SUPER, MOUSE_LEFT_CLICK), hl.dsp.window.drag(), { mouse = true })

-- Resize window with SUPER + right click
hl.bind(key(SUPER, MOUSE_RIGHT_CLICK), hl.dsp.window.resize(), { mouse = true })

-- }}}
