vim.loader.enable()  -- Use compiled and cached files

--- Load one of my scripts
--- @param script_name string Name of the script inside the './lua/my_scripts/' folder (without the '.lua' extension)
local function load_script(script_name)
	require('my_scripts/' .. script_name)
end


-- Dependencies (must be loaded first because other files depend on them)
load_script('paths')  -- Should be loaded first
load_script('functions')


-- Configuration
load_script('setup') -- Add a function and command to run custom setup (need to be load to use them)
load_script('custom_events')
load_script('options')
load_script('themes')
load_script('spell')
load_script('maps')  -- The mapleader keys are defined in this file and need to be loaded before Lazy.nvim


-- Tools
load_script('whitespace')
load_script('indent')
load_script('prose')
load_script('virtual_edit')
load_script('italics')
load_script('LSP')


-- Development options
local lazy_dev = false                             -- Use the 'lazy.nvim' repository in the development folder

if vim.env.ALLOW_EXTERNAL_SOFTWARE == 'y' then
	-- Lazy.nvim (plugin manager) configuration
	local lazy_path = MYPATHS.lazy_nvim
	if lazy_dev then  -- If the 'dev' option to lazy.nvim is enabled, change the path to the development folder
		lazy_path = MYPATHS.dev .. 'lazy.nvim'
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
	-- These *import* statements are relative to the './lua/' folder in each path in the 'runtimepath'.
	-- You can see this path with ':echo &runtimepath'
	require('lazy').setup({
		{import = 'lazy_plugins'},
		{import = 'lazy_plugins/filetype'},
	}, {
		dev = {
			-- Path where to find plugins if in Dev mode
			path = MYPATHS.dev
		},
		change_detection = {
			-- Does not check changes in the configuration files (it is annoying when editing a plugin file). Restart Nvim to see the changes
			enabled = false
		}
	})

	load_script('colorscheme')
end
