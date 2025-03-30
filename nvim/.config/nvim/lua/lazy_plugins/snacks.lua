return {
	{
		'folke/snacks.nvim',
		priority = 15000,
		lazy = false,

		---@module 'snacks'
		---@type snacks.Config
		opts = {
			image = { enabled = true },
		},
	},
}
