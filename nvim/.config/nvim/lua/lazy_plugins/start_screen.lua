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
					{ icon = ' ', icon_hl = icon_hl, desc = 'Update', group = desc_hl, action = 'Lazy update', key = 'u' },
					{ icon = ' ', icon_hl = icon_hl, desc = 'New file', group = desc_hl, action = 'enew', key = 'n' },
					{ icon = ' ', icon_hl = icon_hl, desc = 'Find file', group = desc_hl, action = 'Telescope find_files', key = 'f' },
					{ icon = ' ', icon_hl = icon_hl, desc = 'Git status', group = desc_hl, action = 'Git | only', key = 'g' },
					{ icon = '󰸟 ', icon_hl = icon_hl, desc = 'Healthchecks', group = desc_hl, action = 'checkhealth', key = 'h' },
					{ icon = ' ', icon_hl = icon_hl, desc = 'Check key maps', group = desc_hl, action = 'checkhealth which-key', key = 'k' },
					{ icon = '󱎘 ', icon_hl = icon_hl, desc = 'Quit', group = desc_hl, action = 'quit', key = 'q' },
				},

				packages = { enable = true }  -- Show installed packages
			},
		}
	}
}
