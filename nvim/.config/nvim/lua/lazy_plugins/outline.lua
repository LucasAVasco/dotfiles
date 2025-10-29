return {
	{
		'stevearc/aerial.nvim',
		dependencies = {
			-- Optional
			'nvim-treesitter/nvim-treesitter',
			'nvim-tree/nvim-web-devicons',
		},

		cmd = {
			'AerialClose',
			'AerialCloseAll',
			'AerialGo',
			'AerialInfo',
			'AerialNavClose',
			'AerialNavOpen',
			'AerialNavToggle',
			'AerialNext',
			'AerialOpen',
			'AerialOpenAll',
			'AerialPrev',
			'AerialToggle',
		},

		keys = {
			{ '<leader>go', '<CMD>AerialToggle<CR>', desc = 'Go to outline window' },
			{ '<leader>gn', '<CMD>AerialNavToggle<CR>', desc = 'Go to navigation window' },
		},

		opts = {
			filter_kind = false, -- Show all symbols

			keymaps = {
				['<tab>'] = 'actions.jump',
			},

			autojump = true,
			close_on_select = true,

			-- Navigation window
			nav = {
				preview = true,
				keymaps = {
					['q'] = 'actions.close',
					['<tab>'] = 'actions.jump',
				},

				-- Appearance {{{

				min_height = { 30, 0.9 },
				max_width = 0.6,
				min_width = { 0.5, 30 },

				-- }}}
			},

			-- Appearance {{{

			layout = {
				min_width = 30,
			},

			show_guides = true,
			guides = {
				last_item = '╰─',
			},

			-- }}}
		},
	},
}
