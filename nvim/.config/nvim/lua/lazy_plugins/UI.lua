return {
	{
		'stevearc/dressing.nvim',
		dependencies = {
			'nvim-telescope/telescope.nvim',
		},

		event = 'VeryLazy',

		opts = {
			input = {
				insert_only = false,  -- enable others modes (like normal)
				relative = 'editor',

				min_width = { 40, 0.6 },
				mappings = {
					n = {
						['<Esc>'] = false,  -- Disable <esc> because this can conflict with the normal mode
						['<A-a>'] = 'Close',
						['<A-q>'] = 'Close',
					},
					i = {
						['<A-a>'] = 'Close',
						['<A-q>'] = 'Close',
					}
				},

				override = function(conf)
					-- Show at the bottom left
					conf.col = 3
					conf.row = vim.opt.lines:get() - 3
					return conf
				end
			},

			select = {
				insert_only = false,  -- enable others modes (like normal)
				relative = 'editor',
				backend = { 'telescope' },
			}
		}
	}
}
