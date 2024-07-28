--[[
	Plugins related to finders

	Add an API to lazy load Telescope extensions. The user can use the `MYPLUGFUNC.load_telescope_extension()` function to lazy load the
	extension pickers.

	Telescope extensions loaded with the `MYPLUGFUNC.load_telescope_extension()` function are all lazy loaded, so the plugin that provided
	the extension will not be loaded until the extension is executed or another routine loads the plugin. You should call the
	`MYPLUGFUNC.load_telescope_extension()` function in the `init` function of your `Lazy.nvim` configuration, so that it is available even
	if the plugin is not yet loaded.

	Telescope extensions can only be loaded after Telescope is configured. To allow the user to use `MYPLUGFUNC.load_telescope_extension()`
	before it, this function will save the extension data and load it after Telescope configuration.
]]


-- #region API to lazy load Telescope extensions

--- If the user can lazy load a Telescope extension (true) or need to save it in the `extensions_to_lazy_load` variable (false)
local can_lazy_load_extensions = false

--- Extensions to lazy load after Telescope startup
local extensions_to_lazy_load = {}


--- Check if all pickers are lazy loaded
--- Shows a notification if the user does not lazy loaded all pickers
--- @param lazy_pickers table<string, any> Table that maps the lazy loaded pickers to anything
--- @param real_pickers table<string, any> Table that maps the real pickers to anything
--- @param name string Name of the extension
local function check_lazy_loaded_pickers(lazy_pickers, real_pickers, name)
	for real_picker, _ in pairs(real_pickers) do
		if lazy_pickers[real_picker] == nil then
			vim.notify( {
				('The "%s" picker is not lazy loaded.'):format(real_picker),
				('This means that the user can not run it with ":Telescope %s" before loading the extension.'):format(real_picker),
				('Extension name = "%s"'):format(name),
				'',
				('To fix this warning, you need to go to your `lazy.nvim` configuration and add the "%s"'):format(real_picker),
				'picker to the extension configuration in the "MYPLUGFUNC.load_telescope_extension()" function.'
			}, vim.log.levels.WARN, {
				title = 'Telescope picker not Lazy loaded!',
			})
		end
	end
end


--- Lazy load a Telescope extension (effective version)
--- Create the pickers that will load the actual extension and its pickers when selected. Can NOT be called before Telescope setup
--- @param name string Name of the extension. Same value given to the `require('telescope').load_extension()` function
--- @param pickers table<string> Name of the pickers that the extension provides
local function lazy_load_telescope_extension(name, pickers)
	local telescope = require('telescope')
	local new_lazy_extension = {}

	for _, picker in pairs(pickers) do
		new_lazy_extension[picker] = function(opts)
			local lazy_extension = telescope.extensions[name]
			telescope.extensions[name] = nil                      -- Removes the lazy extension
			local real_extension = telescope.load_extension(name) -- Loads the real extension

			-- Checks if the user provided all pickers in the *pickers* argument
			check_lazy_loaded_pickers(lazy_extension, real_extension, name)

			-- Calls the picker. Otherwise, the first call to the picker would not run the it
			telescope.extensions[name][picker](opts)
		end
	end

	telescope.extensions[name] = new_lazy_extension
end


--- Lazy load a Telescope extension
--- Create the pickers that will load the actual extension and its pickers when selected. Can be called before Telescope setup
--- @param name string Name of the extension. Same value given to the `require('telescope').load_extension()` function
--- @param pickers table<string> Name of the pickers that the extension provides
function MYPLUGFUNC.load_telescope_extension(name, pickers)
	if can_lazy_load_extensions then
		lazy_load_telescope_extension(name, pickers)
	else
		table.insert(extensions_to_lazy_load, {name, pickers})
	end
end

-- #endregion


return {
	{
		'nvim-telescope/telescope.nvim',

		dependencies = {
			'nvim-lua/plenary.nvim',
		},

		lazy = true,

		cmd = 'Telescope',

		keys = {
			{'<leader>gb', '<CMD>Telescope buffers<CR>', desc = 'Select a buffer with Telescope and go to it' },
			{'<leader>gf', '<CMD>Telescope find_files<CR>', desc = 'Select a file with Telescope and open it' },
		},

		config = function()
			local telescope = require('telescope')

			--- Open Telescope selection in Trouble
			---@param ... any Arguments provided by Telescope to `open()`
			local function open_with_trouble(...)
				require('trouble.sources.telescope').open(...)
			end

			--- Add Telescope selection to Trouble
			---@param ... any Arguments provided by Telescope to `add()`
			local function add_to_trouble(...)
				require('trouble.sources.telescope').add(...)
			end

			local tl_actions = require('telescope.actions')

			telescope.setup({
				defaults = {
					mappings = {
						n = {
							['<Esc>'] = false,  -- Disable <esc> because this can conflict with the normal mode
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['T'] = open_with_trouble,
							['t'] = add_to_trouble,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
						},
						i = {
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
						}
					}
				}
			})

			-- Lazy loaded extensions (need to be loaded after the basic setup)
			for _, extension in pairs(extensions_to_lazy_load) do
				lazy_load_telescope_extension(extension[1], extension[2])
			end

			-- Telescope is loaded, so the user can lazy load the extensions. Any next call to `MYPLUGFUNC.load_telescope_extension()` will
			-- lazy load the extension instead of save it in the `extensions_to_lazy_load` variable
			can_lazy_load_extensions = true
		end
	},
	{
		'debugloop/telescope-undo.nvim',

		lazy = true,

		init = function()
			MYPLUGFUNC.load_telescope_extension('undo', { 'undo' })
		end
	}
}
