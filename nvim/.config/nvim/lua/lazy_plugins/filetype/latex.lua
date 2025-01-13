return {
	{
		'lervag/vimtex',
		ft = { 'tex', 'latex' },

		init = function()
			vim.g.vimtex_view_method = 'zathura'
		end,
	},
}
