-- Configuration based on the official documentation at: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
-- And on the following video: https://www.youtube.com/watch?v=CEMPq_r8UYQ
local ts_text_objects = {
	select = {
		['i='] = { query = '@assignment.inner', desc = 'Inner assignment' },
		['a='] = { query = '@assignment.outer', desc = 'Outer assignment' },
		['l='] = { query = '@assignment.lhs', desc = 'Left part of assignment' },
		['r='] = { query = '@assignment.rhs', desc = 'Right part of assignment' },
		['ih'] = { query = '@attribute.inner', desc = 'Inner attribute' },
		['ah'] = { query = '@attribute.outer', desc = 'Outer attribute' },
		['ik'] = { query = '@block.inner', desc = 'Inner part of a block' },
		['ak'] = { query = '@block.outer', desc = 'Outer part of a block' },
		['if'] = { query = '@call.inner', desc = 'Inner part of a call' },
		['af'] = { query = '@call.outer', desc = 'Outer part of a call' },
		['i]'] = { query = '@class.inner', desc = 'Inner part of a class' },
		['a]'] = { query = '@class.outer', desc = 'Outer part of a class' },
		['ig'] = { query = '@comment.inner', desc = 'Inner part of comment' },
		['ag'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
		['ii'] = { query = '@conditional.inner', desc = 'Inner part of conditional' },
		['ai'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
		['ie'] = { query = '@frame.inner', desc = 'Inner part of a frame' },
		['ae'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
		['im'] = { query = '@function.inner', desc = 'Inner part of a method/function' },
		['am'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
		['io'] = { query = '@loop.inner', desc = 'Inner part of a loop' },
		['ao'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
		['in'] = { query = '@number.inner', desc = 'Inner part of a number' },
		['iv'] = { query = '@parameter.inner', desc = 'Inner part of a parameter' },
		['av'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
		['ix'] = { query = '@regex.inner', desc = 'Inner part of a regex' },
		['ax'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
		['ir'] = { query = '@return.inner', desc = 'Inner part of a return' },
		['ar'] = { query = '@return.outer', desc = 'Outer part of a return' },
		['ij'] = { query = '@scopename.inner', desc = 'Inner part of a scope name' },
		['aj'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
	},

	swap = {
		swap_previous = {
			['<A-N>'] = { query = '@parameter.inner', desc = 'Swap with previous parameter' },
		},

		swap_next = {
			['<A-n>'] = { query = '@parameter.inner', desc = 'Swap with next parameter' },
		},
	},

	move = {
		goto_previous_start = {
			['[='] = { query = '@assignment.outer', desc = 'Outer assignment' },
			['[h'] = { query = '@attribute.outer', desc = 'Outer attribute' },
			['[k'] = { query = '@block.outer', desc = 'Outer part of a block' },
			['[f'] = { query = '@call.outer', desc = 'Outer part of a call' },
			['[]'] = { query = '@class.outer', desc = 'Outer part of a class' },
			['[g'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
			['[i'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
			['[e'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
			['[m'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
			['[o'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
			['[n'] = { query = '@number.inner', desc = 'Inner part of a number' },
			['[v'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
			['[x'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
			['[r'] = { query = '@return.outer', desc = 'Outer part of a return' },
			['[j'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
		},

		goto_previous_end = {
			['[+'] = { query = '@assignment.outer', desc = 'Outer assignment' },
			['[H'] = { query = '@attribute.outer', desc = 'Outer attribute' },
			['[K'] = { query = '@block.outer', desc = 'Outer part of a block' },
			['[F'] = { query = '@call.outer', desc = 'Outer part of a call' },
			['[['] = { query = '@class.outer', desc = 'Outer part of a class' },
			['[G'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
			['[I'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
			['[E'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
			['[M'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
			['[O'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
			['[V'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
			['[X'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
			['[R'] = { query = '@return.outer', desc = 'Outer part of a return' },
			['[J'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
		},

		goto_next_start = {
			[']='] = { query = '@assignment.outer', desc = 'Outer assignment' },
			[']h'] = { query = '@attribute.outer', desc = 'Outer attribute' },
			[']k'] = { query = '@block.outer', desc = 'Outer part of a block' },
			[']f'] = { query = '@call.outer', desc = 'Outer part of a call' },
			[']]'] = { query = '@class.outer', desc = 'Outer part of a class' },
			[']g'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
			[']i'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
			[']e'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
			[']m'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
			[']o'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
			[']n'] = { query = '@number.inner', desc = 'Inner part of a number' },
			[']v'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
			[']x'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
			[']r'] = { query = '@return.outer', desc = 'Outer part of a return' },
			[']j'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
		},

		goto_next_end = {
			[']+'] = { query = '@assignment.outer', desc = 'Outer assignment' },
			[']H'] = { query = '@attribute.outer', desc = 'Outer attribute' },
			[']K'] = { query = '@block.outer', desc = 'Outer part of a block' },
			[']F'] = { query = '@call.outer', desc = 'Outer part of a call' },
			[']['] = { query = '@class.outer', desc = 'Outer part of a class' },
			[']G'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
			[']I'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
			[']E'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
			[']M'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
			[']O'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
			[']V'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
			[']X'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
			[']R'] = { query = '@return.outer', desc = 'Outer part of a return' },
			[']J'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
		},
	},
}

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
		branch = 'main',

		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},

		--- Configuration based on the official documentation at: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		---@type TSTextObjects.UserConfig
		opts = {

			select = {
				lookahead = true,
				selection_modes = {
					['@parameter.outer'] = 'v',
					['@function.outer'] = 'V',
				},
			},

			move = {
				set_jumps = true,
			},
		},

		--- Configuration for nvim-treesitter-textobjects
		---@param opts TSTextObjects.UserConfig
		config = function(_, opts)
			-- Configuration based on the official documentation at: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
			require('nvim-treesitter-textobjects').setup(opts)

			-- Select text objects

			for k, v in pairs(ts_text_objects.select) do
				vim.keymap.set({ 'x', 'o' }, k, function()
					require('nvim-treesitter-textobjects.select').select_textobject(v.query, 'textobjects')
				end, { desc = v.desc })
			end

			-- Swap text objects

			for k, v in pairs(ts_text_objects.swap.swap_previous) do
				vim.keymap.set({ 'n' }, k, function()
					require('nvim-treesitter-textobjects.swap').swap_previous(v.query)
				end, { desc = v.desc })
			end

			for k, v in pairs(ts_text_objects.swap.swap_next) do
				vim.keymap.set({ 'n' }, k, function()
					require('nvim-treesitter-textobjects.swap').swap_next(v.query)
				end, { desc = v.desc })
			end

			-- Move text objects

			for k, v in pairs(ts_text_objects.move.goto_previous_start) do
				vim.keymap.set({ 'n', 'x', 'o' }, k, function()
					require('nvim-treesitter-textobjects.move').goto_previous_start(v.query, 'textobjects')
				end, { desc = v.desc })
			end

			for k, v in pairs(ts_text_objects.move.goto_previous_end) do
				vim.keymap.set({ 'n', 'x', 'o' }, k, function()
					require('nvim-treesitter-textobjects.move').goto_previous_end(v.query, 'textobjects')
				end, { desc = v.desc })
			end

			for k, v in pairs(ts_text_objects.move.goto_next_start) do
				vim.keymap.set({ 'n', 'x', 'o' }, k, function()
					require('nvim-treesitter-textobjects.move').goto_next_start(v.query, 'textobjects')
				end, { desc = v.desc })
			end

			for k, v in pairs(ts_text_objects.move.goto_next_end) do
				vim.keymap.set({ 'n', 'x', 'o' }, k, function()
					require('nvim-treesitter-textobjects.move').goto_next_end(v.query, 'textobjects')
				end, { desc = v.desc })
			end

			-- Repeat selection, swap and movement

			local ts_repeatable_move = require('nvim-treesitter-textobjects.repeatable_move')

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
	{
		'mizlan/iswap.nvim',

		cmd = {
			'IMove',
			'IMoveNode',
			'IMoveNodeWith',
			'IMoveNodeWithLeft',
			'IMoveNodeWithRight',
			'IMoveWith',
			'IMoveWithLeft',
			'IMoveWithRight',
			'ISwap',
			'ISwapNode',
			'ISwapNodeWith',
			'ISwapNodeWithLeft',
			'ISwapNodeWithRight',
			'ISwapWith',
			'ISwapWithLeft',
			'ISwapWithRight',
		},

		keys = {
			{ '<leader>sn', '<CMD>ISwapNodeWith<CR>', desc = 'Interactively swap node' },
			{ '<leader>sp', '<CMD>ISwap<CR>', desc = 'Interactively swap parameter' },
		},

		opts = {},
	},
}
