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
			image = {
				enabled = true,
				doc = {
					inline = false,
				},
			},
			quickfile = { enabled = true },
			bigfile = { enabled = true },
			lazygit = { enabled = true },
			terminal = {},
			dashboard = require('lazy_plugins.snacks.dashboard'),
			scratch = {},
			picker = {
				ui_select = true,
			},
		},

		config = function(_, opts)
			local snacks = require('snacks')
			snacks.setup(opts)

			vim.api.nvim_create_user_command('Colorize', function(args)
				snacks.terminal.colorize()
			end, {})

			-- LazyGit
			vim.api.nvim_create_user_command('Lazygit', function()
				snacks.lazygit.open()
			end, {})

			-- Scratch
			vim.api.nvim_create_user_command('Scratch', function()
				snacks.scratch()
			end, { desc = 'Toggle scratch buffer' })

			vim.api.nvim_create_user_command('ScratchSelect', function()
				snacks.scratch.select()
			end, { desc = 'Select scratch buffer' })

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
