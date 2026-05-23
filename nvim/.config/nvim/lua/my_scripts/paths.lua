local data = vim.fn.stdpath('data') --[[@as string]]

---@type string
local home = vim.env.HOME
local config_folder_rel_to_home = '.config/nvim/'
local config = home .. '/' .. config_folder_rel_to_home
local config_lua = config .. '/lua/'
local mason = data .. '/mason/'

MYPATHS = {
	home = home,
	config = config,
	config_folder_rel_to_home = config_folder_rel_to_home,
	dev = home .. '/Repositories/neovim_repos/', -- Development folder (used to load plugins in 'dev' mode)
	org = home .. '/Org', -- Organization related data (notes, agenda, etc)
	data = data,
	lazy_nvim = data .. '/lazy/lazy.nvim/', -- Where to install Lazy.nvim

	-- Plugins
	plugins = config_lua .. '/lazy_plugins/',
	plugin_empty = config .. '/empty_plugin/', -- Folder to be used as 'dir' in local plugins
	plugins_ft = config_lua .. '/lazy_plugins/filetype/',

	-- `mason.nvim`
	mason = mason,
	mason_packages = mason .. '/packages/',
}
