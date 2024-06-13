-- Override the default `vim.notify` function to a function that loads 'nvim-notify' before showing the notification.
-- This allows the 'nvim-notify' plugin to be lazy loaded. It will be loaded only when the first notification be sent
vim.notify = function(msg, level, opts)
	require('notify')

	vim.notify(msg, level, opts)
end


return {
	{
		'rcarriga/nvim-notify',
		lazy = true,
		priority = 9500,

		config = function()
			vim.notify = require('notify')
		end
	}
}
