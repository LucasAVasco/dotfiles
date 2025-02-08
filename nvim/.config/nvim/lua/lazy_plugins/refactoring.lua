return {
	{
		'ThePrimeagen/refactoring.nvim',

		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
		},

		cmd = 'Refactor',

		keys = {
			{
				'<leader>R.',
				function()
					require('telescope').extensions.refactoring.refactors()
				end,
				mode = { 'n', 'x' },
				desc = 'Show Telescope UI',
			},
			{
				'<leader>Rp',
				function()
					require('refactoring').debug.printf({ below = false })
				end,
				desc = 'Add print statement',
			},
			{
				'<leader>Rv',
				function()
					require('refactoring').debug.print_var({})
				end,
				mode = { 'n', 'x' },
				desc = 'Print variable value',
			},
			{
				'<leader>Rc',
				function()
					require('refactoring').debug.cleanup({})
				end,
				desc = 'Clear generated `prints`',
			},
		},

		opts = {},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>R', 'Refactoring keymaps')

			MYPLUGFUNC.load_telescope_extension('refactoring', { 'refactors' })
		end,
	},
}
