-- Override the default `vim.ui.input` function to a function that loads 'dressing.nvim' before showing the pop up.
-- This allows the 'dressing.nvim' plugin to be lazy loaded. It will be loaded only when the first input be required
vim.ui.input = function(opts, callback_input)
	require('dressing')

	vim.ui.input(opts, callback_input)
end


-- Like the `vim.ui.input` override, but to `vim.ui.select` function
vim.ui.select = function(iten_list, opts, callback_select)
	require('dressing')

	vim.ui.select(iten_list, opts, callback_select)
end


return {
	{
		'stevearc/dressing.nvim',

		lazy = true,

		dependencies = {
			'nvim-telescope/telescope.nvim',
		},

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
