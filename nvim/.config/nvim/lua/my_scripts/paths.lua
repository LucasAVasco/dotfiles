local data = vim.fn.stdpath('data') --[[@as string]]

---@type table<string, string>
MYPATHS = {
	home = vim.env.HOME,
	config = vim.env.HOME .. '/.config/nvim/',
	dev = vim.env.HOME .. '/Repositories/neovim_repos/', -- Development folder (used to load plugins in 'dev' mode)
	data = data,
	lazy_nvim = data .. '/lazy/lazy.nvim/', -- Where to install Lazy.nvim

	-- Plugins
	plugins = vim.env.HOME .. '/.config/nvim/lua/lazy_plugins/',
	plugin_empty = vim.env.HOME .. '/.config/nvim/empty_plugin/', -- Folder to be used as 'dir' in local plugins
	plugins_ft = vim.env.HOME .. '/.config/nvim/lua/lazy_plugins/filetype/',

	-- `mason.nvim`
	mason = data .. '/mason/',
	mason_packages = data .. '/mason/packages/',
}
