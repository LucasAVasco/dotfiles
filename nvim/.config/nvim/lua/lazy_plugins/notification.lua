--- Shows a notification with `nvim-notify` plugin
--- Override the default `vim.notify` function to a function that loads 'nvim-notify' before showing the notification. This allows the
--- 'nvim-notify' plugin to be lazy loaded. The first call to this function will load the `nvim-notify` plugin, and my `lazy.nvim`
--- configuration will replace the function by the one provided by this plugin
---@param msg string Body of the message
---@param level? number Notification level number (vim.log.levels) or a string with the name of the level. E.g. 'error'.
---@param opts? notify.Options Options table to send to `nvim-notify` plugin
---@module 'nvim-notify'
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
	require('notify')

	vim.notify(msg, level, opts)
end

return {
	{
		'rcarriga/nvim-notify',
		lazy = true,
		priority = 9500, -- Notification system

		opts = {
			top_down = false,
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
