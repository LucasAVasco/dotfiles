return {
	{
		'romgrk/barbar.nvim',

		dependencies = {
			'lewis6991/gitsigns.nvim',
			'nvim-tree/nvim-web-devicons',
		},

		opts = {
			-- File types to be treated as sidebars. BarBar will offset the bar from them
			sidebar_filetypes = {
				NvimTree = true,
			},
		},

		config = function(plugin, opts)
			require('barbar').setup(opts)

			local get_map_opts = myfunc.decorator_create_options_table({
				silent = true,
				noremap = true,
			})

			-- Mappings to move through buffers
			vim.keymap.set('n', '<A-0>', '<Cmd>BufferLast<CR>', get_map_opts('Go to last buffer'))
			vim.keymap.set('n', '<A-q>', '<Cmd>BufferClose<CR>', get_map_opts('Close current buffer'))

			for i = 1, 9 do
				-- Go to a specific buffer
				vim.keymap.set('n', '<A-' .. i .. '>', '<Cmd>BufferGoto ' .. i .. '<CR>', get_map_opts('Go to buffer ' .. i))
			end

			-- Group of key maps to manage buffers
			myplugfunc.set_keymap_name('<leader>B', 'Buffer keymaps')
			vim.keymap.set('n', '<leader>Bg', '<Cmd>BufferPick<CR>', get_map_opts('Interactively select a buffer to go'))
			vim.keymap.set('n', '<leader>Bp', '<Cmd>BufferPin<CR>', get_map_opts('Toggle the Pin state of the current buffer'))

			-- Group of key maps to sort (order) buffers
			myplugfunc.set_keymap_name('<leader>BO', 'Buffer order keymaps')
			vim.keymap.set('n', '<leader>BOd', '<Cmd>BufferOrderByDirectory<CR>', get_map_opts('Sort buffers by directory'))
			vim.keymap.set('n', '<leader>BOa', '<Cmd>BufferOrderByName<CR>', get_map_opts('Sort buffers by buffer name'))
			vim.keymap.set('n', '<leader>BOl', '<Cmd>BufferOrderByLanguage<CR>', get_map_opts('Sort buffers by language'))
			vim.keymap.set('n', '<leader>BOn', '<Cmd>BufferOrderByBufferNumber<CR>', get_map_opts('Sort buffers by buffer number'))
			vim.keymap.set('n', '<leader>BOw', '<Cmd>BufferOrderByWindowNumber<CR>', get_map_opts('Sort buffers by window number'))
		end
	},
	{
		'vim-airline/vim-airline',

		dependencies = {
			'vim-airline/vim-airline-themes'
		},

		init = function()
			vim.g.airline_left_sep = ''
			vim.g.airline_right_sep = ''
			vim.g.airline_left_alt_sep = ''
			vim.g.airline_right_alt_sep = ''

			vim.g['airline#extensions#tabline#left_sep'] = ' '
			vim.g['airline#extensions#tabline#right_sep'] = ' '
			vim.g['airline#extensions#tabline#left_alt_sep'] = '┃'
			vim.g['airline#extensions#tabline#right_alt_sep'] = ' '

			-- Themes
			vim.g.airline_theme = 'base16_gruvbox_dark_pale'
		end
	}
}
