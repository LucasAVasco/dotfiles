return {
	{
		'ellisonleao/gruvbox.nvim',

		lazy = false,
		priority = 8500,

		config = function()
			vim.api.nvim_exec([[
			syntax enable
			colorscheme gruvbox
			]],
			false -- do not return anything
			)
		end
	}
}
