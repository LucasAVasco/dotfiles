_G.mypaths = {
	config = vim.env.HOME .. '/.config/nvim/',
	dev = vim.env.HOME .. '/Repositories/',                        -- Development folder (used to load plugins in 'dev' mode)
	lazy_nvim = vim.fn.stdpath('data') .. '/lazy/lazy.nvim',       -- Where to install Lazy.nvim

	-- Plugins
	plugins = vim.env.HOME .. '/.config/nvim/lua/lazy_plugins/',
	plugin_empty = vim.env.HOME .. '/.config/nvim/empty_plugin/',  -- Folder to be used as 'dir' in local plugins
	plugins_ft = vim.env.HOME .. '/.config/nvim/lua/lazy_plugins/filetype/',
	plugins_LSP = vim.env.HOME .. '/.config/nvim/lua/lazy_plugins/LSP',
	plugins_local = vim.env.HOME .. '/.config/nvim/local_plugins/',
}
