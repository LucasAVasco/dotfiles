return {
	{
		-- This plugin improves the text objects related to 'a' and 'i'. This is not plugin related to artificial intelligence
		'echasnovski/mini.ai',
		version = false,

		config = function()
			require('mini.ai').setup()
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter-textobjects',

		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},

		config = function()
			-- Configuration based on the official documentation at: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

			-- Repeat selection, swap and movement

			local ts_repeatable_move = require('nvim-treesitter.textobjects.repeatable_move')

			local modes = { 'n', 'o', 'x' }
			local get_opts = MYFUNC.decorator_create_options_table({
				remap = false,
			})
			vim.keymap.set(modes, ',', ts_repeatable_move.repeat_last_move_previous, get_opts('Previous repeated text object'))
			vim.keymap.set(modes, ';', ts_repeatable_move.repeat_last_move_next, get_opts('Next repeated text object'))

			-- Overrides 'f', 'F', 't', and 'T'

			local get_opts_expr = MYFUNC.decorator_create_options_table({
				remap = false,
				expr = true,
			})
			vim.keymap.set(modes, 'F', ts_repeatable_move.builtin_F_expr, get_opts_expr('Move previous char'))
			vim.keymap.set(modes, 'T', ts_repeatable_move.builtin_T_expr, get_opts_expr('Move before previous char'))
			vim.keymap.set(modes, 'f', ts_repeatable_move.builtin_f_expr, get_opts_expr('Move next char'))
			vim.keymap.set(modes, 't', ts_repeatable_move.builtin_t_expr, get_opts_expr('Move before next char'))
		end,
	},
	{
		'folke/flash.nvim',

		keys = {
			{
				'<leader>Ft',
				function()
					require('flash').toggle()
				end,
				desc = 'Toggle Flash in search mode',
			},
			{
				'r',
				mode = { 'o' }, -- Flash remote motion
				function()
					require('flash').remote()
				end,
				desc = 'At another position given by Flash',
			},
			{
				'<A-f>',
				mode = { 'n', 'v', 'o' }, -- Jump in normal and visual mode
				function()
					require('flash').jump()
				end,
				desc = 'To a position given by Flash',
			},
			{
				'<A-t>',
				mode = { 'n', 'v', 'o' }, -- Select in normal and visual mode
				function()
					require('flash').treesitter()
				end,
				desc = 'A treesitter area with Flash',
			},
			{
				'<A-s>',
				mode = { 'n', 'v', 'o' }, -- Select in normal mode, jump in visual mode
				function()
					require('flash').treesitter_search()
				end,
				desc = 'A search and treesitter area given by Flash',
			},
		},

		opts = {
			modes = {
				char = {
					jump_labels = true,
				},
			},
		},
	},
}
