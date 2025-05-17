return {
	{
		'rcarriga/nvim-notify',
		lazy = true,
		priority = 9500, -- Notification system

		opts = {
			top_down = false,
			render = 'wrapped-default',
		},

		cmd = {
			'Notifications',
			'NotificationsClear',

			-- My commands
			'NotificationsDismiss',
		},

		init = function()
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
