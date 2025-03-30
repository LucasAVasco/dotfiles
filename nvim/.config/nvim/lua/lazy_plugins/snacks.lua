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

			-- LazyGit
			vim.api.nvim_create_user_command('Lazygit', function()
				snacks.lazygit.open()
			end, {})

			---Debug object
			---@class my.debug.object
			---@field print fun(...)
			---@field backtrace fun()
			_G.vim.debug = {
				print = snacks.debug.inspect,
				backtrace = snacks.debug.backtrace,
			}
			vim.print = snacks.debug.inspect
		end,
	},
}
