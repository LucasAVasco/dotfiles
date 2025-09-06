return {
	{
		'brenoprata10/nvim-highlight-colors',

		opts = {
			enable_tailwind = true,
		},

		config = function(_, opts)
			require('nvim-highlight-colors').setup(opts)
		end,
	},
	{
		'hiphish/rainbow-delimiters.nvim',
	},
	{
		'https://github.com/RRethy/vim-illuminate',

		opts = {
			disable_keymaps = false,
		},

		config = function(_, opts)
			require('illuminate').configure(opts)
		end,
	},
}
