--- Shows the input pop up with `dressing.nvim` plugin
--- Override the default `vim.ui.input` function to a function that loads `dressing.nvim` before showing the pop up. This allows the
--- `dressing.nvim` plugin to be lazy loaded. The first call to this function will load the `dressing.nvim` plugin, and it will replace the
--- function by the one provided by this plugin
---@param opts table Options to be sent to `dressing.nvim`
---@param callback_input fun(text: string|nil) Function called after the user provide the input. Receives the user input as parameter
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.input = function(opts, callback_input)
	require('dressing')

	vim.ui.input(opts, callback_input)
end


--- Shows the select pop up with `dressing.nvim` plugin
--- Override the default `vim.ui.select` function to a function that loads `dressing.nvim` before showing the pop up. This allows the
--- `dressing.nvim` plugin to be lazy loaded. The first call to this function will load the `dressing.nvim` plugin, and it will replace the
--- function by the one provided by this plugin
---@param item_list table Tens that the user can select
---@param opts table Options to send to `dressing.nvim`
---@param callback_select fun(selected_item: string|nil, item_index: number|nil)  Function called after the user select a item
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(item_list, opts, callback_select)
	require('dressing')

	vim.ui.select(item_list, opts, callback_select)
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
