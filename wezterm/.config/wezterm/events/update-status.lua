local wezterm = require('wezterm')
local colors = require('wez-colors')

---@diagnostic disable-next-line: unused-local
wezterm.on('update-status', function(window_gui, active_pane)
	local normal_bg = colors.color_window_name_bg
	local normal_fg = colors.color_left_fg
	local tab_bar_bg = colors.tab_bar_bg

	window_gui:set_left_status(wezterm.format({
		{ Background = { Color = tab_bar_bg } },
		{ Foreground = { Color = normal_bg } },
		{ Text = '  ' },
		{ Background = { Color = normal_bg } },
		{ Foreground = { Color = normal_fg } },
		{ Text = '  ' },
		{ Foreground = { Color = normal_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = '  ' },
	}))

	window_gui:set_right_status(wezterm.format({
		{ Background = { Color = tab_bar_bg } },
		{ Foreground = { Color = normal_bg } },
		{ Text = '  ' },
		{ Background = { Color = normal_bg } },
		{ Foreground = { Color = normal_fg } },
		{ Text = '  ' },
		{ Foreground = { Color = normal_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = '  ' },
	}))
end)
