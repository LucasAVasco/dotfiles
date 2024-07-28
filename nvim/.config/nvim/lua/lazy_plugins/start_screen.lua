local icon_hl = '@label'
local desc_hl = '@string'


return {
	{
		'nvimdev/dashboard-nvim',
		event = 'VimEnter',

		dependencies = {
			'nvim-tree/nvim-web-devicons'
		},

		opts = {
			theme = 'hyper',
			shortcut_type = 'number',
			config = {
				week_header = {
					enable = true
				},

				shortcut = {
					{ icon = ' ', key = 'p', icon_hl = icon_hl, desc = 'Plugins', group = desc_hl, action = 'Lazy'},
					{ icon = ' ', key = 'n', icon_hl = icon_hl, desc = 'New file', group = desc_hl, action = 'new | only'},
					{ icon = ' ', key = 't', icon_hl = icon_hl, desc = 'File tree', group = desc_hl, action = 'NvimTreeFocus'},
					{ icon = '󰖌 ', key = 'o', icon_hl = icon_hl, desc = 'Oil nvim', group = desc_hl, action = 'Oil'},
					{ icon = ' ', key = 'f', icon_hl = icon_hl, desc = 'Find file', group = desc_hl, action = 'Telescope find_files'},
					{ icon = ' ', key = 'G', icon_hl = icon_hl, desc = 'Git status', group = desc_hl, action = 'Git | only'},
					{ icon = '󱃆 ', key = 's', icon_hl = icon_hl, desc = 'List NOPUSH comments', group = desc_hl,
						action = 'TodoTelescope keywords=NOPUSH'},
					{ icon = '󰸟 ', key = 'h', icon_hl = icon_hl, desc = 'Healthchecks', group = desc_hl,
						action = 'Lazy load all | checkhealth'},
					{ icon = ' ', key = 'k', icon_hl = icon_hl, desc = 'Check key maps', group = desc_hl,
						action = 'Lazy load all | checkhealth which-key'},
					{ icon = '󱎘 ', key = 'q', icon_hl = icon_hl, desc = 'Quit', group = desc_hl, action = 'quit'},
				},

				packages = { enable = true },  -- Show installed packages

				footer = {},
			},

		}
	}
}
