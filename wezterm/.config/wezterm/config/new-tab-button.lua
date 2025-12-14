local colors = require('wez-colors')
local wezterm = require('wezterm')

local tab_bar_bg = colors.tab_bar_bg
local new_tab_fg = colors.color_window_status_current
local new_tab_bg = colors.color_window_name_bg
local new_tab_hover_bg = colors.color_window_status_inactive

local Config = {
	new_tab = wezterm.format({
		{ Foreground = { Color = new_tab_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = '' },
		{ Background = { Color = new_tab_bg } },
		{ Foreground = { Color = new_tab_fg } },
		{ Text = '+' },
		{ Foreground = { Color = new_tab_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = ' ' },
	}),
	new_tab_hover = wezterm.format({
		{ Foreground = { Color = new_tab_hover_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = '' },
		{ Background = { Color = new_tab_hover_bg } },
		{ Foreground = { Color = new_tab_fg } },
		{ Text = '+' },
		{ Foreground = { Color = new_tab_hover_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = ' ' },
	}),
}

return Config
