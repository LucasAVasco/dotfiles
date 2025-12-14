local wezterm = require('wezterm')
local colors = require('wez-colors')
local tab_bar = require('libs.tab_bar')
local input_prompt = require('libs.input_prompt')

-- Left status {{{

local normal_bg = colors.color_window_name_bg
local normal_fg = colors.color_left_fg
local tab_bar_bg = colors.tab_bar_bg

local left_status = wezterm.format({
	{ Background = { Color = tab_bar_bg } },
	{ Foreground = { Color = normal_bg } },
	{ Text = '  ' },
	{ Background = { Color = normal_bg } },
	{ Foreground = { Color = normal_fg } },
	{ Text = '  ' },
	{ Foreground = { Color = normal_bg } },
	{ Background = { Color = tab_bar_bg } },
	{ Text = '  ' },
})

-- }}}

local last_right_status_command = ''

---Get the text to show in the right status
---@param active_pane any
---@return string
local function get_right_status_command(active_pane)
	local current_input, last_input = input_prompt.get_current_and_last_inputs(active_pane)
	local text = current_input
	if text == '' then
		text = last_input
	end

	-- The output line does not support newlines
	text = text:gsub('\n', ' ')

	-- Backups the last right status command
	if text == '' then
		text = last_right_status_command
	else
		last_right_status_command = text
	end

	return text
end

---Get the right status formatted with `wezterm.format()`
---@param command string
---@return any
local function get_right_status(command)
	-- Formats the text
	if command ~= '' then
		command = ' ' .. command:sub(1, 100) .. ' '
	end

	return wezterm.format({
		{ Foreground = { Color = '#88bbff' } },
		{ Text = command },
	})
end

---@diagnostic disable-next-line: unused-local
wezterm.on('update-status', function(window_gui, active_pane)
	---Text to show at the right.
	---NOTE(LucasAVasco): If the command outputs many lines at a time, this function may not retrieve the command. To avoid this issue, run
	---this function first
	local command = get_right_status_command(active_pane)

	-- Only visible if the window is not at the start of the scrollback and the command is not empty

	local dimensions = active_pane:get_dimensions()
	local visible = dimensions.physical_top - 2 > dimensions.scrollback_top and command ~= ''

	tab_bar.set_visibility_single_tab(window_gui, visible)

	-- Left status
	window_gui:set_left_status(left_status)

	-- Right status
	if visible then
		window_gui:set_right_status(get_right_status(command))
	end
end)
