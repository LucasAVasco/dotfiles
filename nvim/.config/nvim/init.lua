-- Options
local config_dir = vim.env.HOME .. '/.config/nvim/'


-- Dependencies (must be loaded first because other files depend on them)
dofile(config_dir .. 'paths.lua')  -- Should be loaded first
dofile(config_dir .. 'functions.lua')


-- Configuration
dofile(config_dir .. 'setup.lua')      -- Add a function and command to run custom setup (need to be load to use them)
dofile(config_dir .. 'options.lua')
dofile(config_dir .. 'themes.lua')
dofile(config_dir .. 'spell.lua')
dofile(config_dir .. 'maps.lua')  -- The mapleader keys are defined in this file and need to be loaded before Lazy.nvim


-- Tools
dofile(config_dir .. 'whitespace.lua')
dofile(config_dir .. 'prose.lua')
dofile(config_dir .. 'virtual_edit.lua')
dofile(config_dir .. 'italics.lua')
dofile(config_dir .. 'LSP.lua')


-- Development options
local lazy_dev = false                             -- Use the 'lazy.nvim' repository in the development folder

-- Lazy.nvim (plugin manager) configuration
local lazy_path = mypaths.lazy_nvim
if lazy_dev then  -- If the 'dev' option to lazy.nvim is enabled, change the path to the development folder
	lazy_path = mypaths.dev .. 'lazy.nvim'
end
if not vim.uv.fs_stat(lazy_path) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazy_path,
		})
end

vim.opt.rtp:prepend(lazy_path)

-- Load all plugins files. Each *.lua file inside the folder specified in the *import* statement will be loaded.
-- These *import* satements are relative to the './lua/' folder in each path in the 'runtimepath'.
-- You can see this path with ':echo &runtimepath'
require('lazy').setup({
	{import = 'lazy_plugins'},
	{import = 'lazy_plugins/filetype'},
	{import = 'lazy_plugins/LSP'},
}, {
	dev = {
		-- Path where to find plugins if in Dev mode
		path = mypaths.dev
	},
	change_detection = {
		-- Does not check changes in the configuration files (it is annoying when editing a plugin file). Restart Nvim to see the changes
		enabled = false
	}
})
