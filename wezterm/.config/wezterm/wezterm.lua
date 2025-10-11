require('debug') -- Must be first, so debug functions are available in all scripts

local wezterm = require('wezterm')
local colors = require('wez-colors')
local config = wezterm.config_builder()

require('events.all')

-- Appearance

config.color_scheme = 'My Custom Theme'
config.bold_brightens_ansi_colors = false
config.window_background_opacity = 0.7
config.colors = {
	tab_bar = {
		background = colors.tab_bar_bg,
	},
}
config.inactive_pane_hsb = {
	brightness = 0.7,
	saturation = 0.9,
}

-- Fonts

config.font_size = 12.0
config.use_cap_height_to_scale_fallback_fonts = true
if os.getenv('ALLOW_EXTERNAL_SOFTWARE') == 'y' then
	config.font = wezterm.font_with_fallback({
		{
			family = 'JetBrainsMono Nerd Font Mono',
		},
		{
			family = 'Noto Color Emoji',
			assume_emoji_presentation = true,
		},
	})
end

-- Environment variables

config.set_environment_variables = {
	SHELL = '/bin/zsh',
	TERMINAL_EMULATOR = 'wezterm',
}

-- Key binds

config.leader = { key = 'q', mods = 'SUPER', timeout_milliseconds = 1000 }
local key_binds = require('config.keys')
config.keys = key_binds.keys
config.key_tables = key_binds.key_tables

-- Tab-bar

config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 20
config.use_fancy_tab_bar = false
config.tab_bar_style = require('config.new-tab-button')

return config
