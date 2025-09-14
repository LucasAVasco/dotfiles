return {
	{
		'rcarriga/nvim-notify',
		lazy = true,
		priority = 9500, -- Notification system

		opts = {
			top_down = false,
			render = 'default',

			max_width = function()
				return math.floor(vim.o.columns * 0.4)
			end,

			max_height = function()
				return math.floor(vim.o.lines * 0.5)
			end,
		},

		cmd = {
			'Notifications',
			'NotificationsClear',

			-- My commands
			'NotificationsDismiss',
		},

		keys = {
			{ '<leader>Nd', '<CMD>NotificationsDismiss<CR>', desc = 'Dismiss all notifications' },
			{ '<leader>Nl', '<CMD>Telescope notify<CR>', desc = 'List all notifications' },
			{ '<leader>Ns', '<CMD>Notifications<CR>', desc = 'Show all notifications' },
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>N', 'Notifications key maps')
			MYPLUGFUNC.load_telescope_extension('notify', { 'notify' })
		end,

		config = function(_, opts)
			local notify = require('notify')
			notify.setup(opts)

			-- Override the default function
			vim.notify = notify

			vim.api.nvim_create_user_command('NotificationsDismiss', function()
				notify.dismiss({
					pending = true,
					silent = false,
				})
			end, {
				desc = 'Dismiss all notifications',
			})
		end,
	},
}
