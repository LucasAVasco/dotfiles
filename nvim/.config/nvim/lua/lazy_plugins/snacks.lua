return {
	{
		'folke/snacks.nvim',
		priority = 15000,
		lazy = false,

		cmd = {
			'Lazygit',
		},

		---@module 'snacks'
		---@type snacks.Config
		opts = {
			image = { enabled = true },
			quickfile = { enabled = true },
			bigfile = { enabled = true },
			lazygit = { enabled = true },
		},

		config = function(_, opts)
			local snacks = require('snacks')
			snacks.setup(opts)

			vim.api.nvim_create_user_command('Lazygit', function()
				snacks.lazygit.open()
			end, {})
		end,
	},
}
