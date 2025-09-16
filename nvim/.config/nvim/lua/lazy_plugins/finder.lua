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
	for real_picker_name, _ in pairs(real_pickers) do
		if lazy_pickers[real_picker_name] == nil then
			vim.notify(
				(
					'The "%s" picker is not lazy loaded.\n'
					.. 'This means that the user can not run it with ":Telescope %s %s" before loading the extension.\n'
					.. 'Extension name = "%s"\n'
					.. 'To fix this warning, you need to go to your `lazy.nvim` configuration and add the "%s"\n'
					.. 'picker to the extension configuration in the "MYPLUGFUNC.load_telescope_extension()" function.\n'
				):format(real_picker_name, name, real_picker_name, name, real_picker_name),
				vim.log.levels.WARN,
				{
					title = 'Telescope picker not Lazy loaded!',
				}
			)
		end
	end
end

--- Lazy load a Telescope extension (effective version)
--- Create the pickers that will load the actual extension and its pickers when selected. Can NOT be called before Telescope setup
--- @param name string Name of the extension. Same value given to the `require('telescope').load_extension()` function
--- @param pickers string[] Name of the pickers that the extension provides
local function lazy_load_telescope_extension(name, pickers)
	local telescope = require('telescope')
	local new_lazy_extension = {}

	for _, picker in pairs(pickers) do
		new_lazy_extension[picker] = function(opts)
			local lazy_extension = telescope.extensions[name]
			telescope.extensions[name] = nil -- Removes the lazy extension
			local real_extension = telescope.load_extension(name) -- Loads the real extension

			-- Checks if the user provided all pickers in the *pickers* argument
			check_lazy_loaded_pickers(lazy_extension, real_extension, name)

			-- Calls the picker. Otherwise, the first call to the picker would not run it
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
		table.insert(extensions_to_lazy_load, { name, pickers })
	end
end

-- #endregion

local normal_and_visual_modes = { 'n', 'x' }

return {
	{
		'nvim-telescope/telescope.nvim',

		dependencies = {
			'nvim-lua/plenary.nvim',
		},

		lazy = true,

		cmd = 'Telescope',

		keys = {
			{ '<leader>gb', '<CMD>Telescope buffers<CR>', desc = 'Select a buffer with Telescope and go to it' },
			{ '<leader>gff', '<CMD>Telescope find_files<CR>', desc = 'Select files with Telescope and open them' },
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

			---Close the current picker and edit all selected files.
			---You can select a file with `TAB` and `S-TAB`. If this function can not query the selected files (E.g. The user does not
			---selected any file), use the default `<CR>` behavior (select the default option of the buffer).
			---@param tl_prompt_buffer number Buffer of the current Telescope prompt
			local function edit_selected_files(tl_prompt_buffer)
				local tl_action_state = require('telescope.actions.state')
				local picker = tl_action_state.get_current_picker(tl_prompt_buffer)

				---Selected files to open
				local selections = {}
				if picker.get_multi_selection then
					selections = picker:get_multi_selection()
				end

				---@class DataToOpenFile
				---@field path string Path of the file to open
				---@field col? number Open in this column (first column has index 1)
				---@field line? number Open in this line (first line has index 1)
				---@package

				---Files to edit
				---@type DataToOpenFile[]
				local files = {}
				for _, selected_entry in pairs(selections) do
					---@type DataToOpenFile
					local file_data = {
						path = selected_entry.filename or selected_entry[1], -- Some pickers use the first element as the file path
						col = selected_entry.col,
						line = selected_entry.lnum,
					}

					if file_data.path then
						table.insert(files, file_data)
					end
				end

				-- Can not query the file paths. Use the default key map of `<CR>`: `select_default` function
				if #files == 0 then
					tl_actions.select_default(tl_prompt_buffer)
					return
				end

				-- Need to close telescope before editing the files. Otherwise, Neovim throws an error because the content of the prompt
				-- buffer is not saved
				tl_actions.close(tl_prompt_buffer)

				for _, file2open in pairs(files) do
					-- Open the file
					vim.cmd.edit({ args = { file2open.path }, magic = { file = false, bar = false } })

					-- Set the cursor position (line and column)
					local normal_cmd = ''

					if file2open.line then
						normal_cmd = normal_cmd .. file2open.line .. 'gg'
					end

					if file2open.col and file2open.col > 0 then
						normal_cmd = normal_cmd .. '0' .. file2open.col .. 'l'
					end

					if normal_cmd ~= '' then
						vim.cmd.normal({ args = { normal_cmd }, bang = true })
					end
				end
			end

			telescope.setup({
				defaults = {
					sorting_strategy = 'ascending',

					layout_config = {
						horizontal = {
							prompt_position = 'top',
						},
						vertical = {
							prompt_position = 'top',
						},
					},

					mappings = {
						n = {
							['<Esc>'] = false, -- Disable <esc> because this can conflict with the normal mode
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['<A-S-q>'] = tl_actions.close,
							['T'] = open_with_trouble,
							['t'] = add_to_trouble,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
							['<CR>'] = edit_selected_files,
						},
						i = {
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['<A-S-q>'] = tl_actions.close,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
							['<CR>'] = edit_selected_files,
						},
					},
				},
			})

			-- Lazy loaded extensions (need to be loaded after the basic setup)
			for _, extension in pairs(extensions_to_lazy_load) do
				lazy_load_telescope_extension(extension[1], extension[2])
			end

			-- Telescope is loaded, so the user can lazy load the extensions. Any next call to `MYPLUGFUNC.load_telescope_extension()` will
			-- lazy load the extension instead of save it in the `extensions_to_lazy_load` variable
			can_lazy_load_extensions = true
		end,
	},
	{
		'ibhagwan/fzf-lua',

		dependencies = 'nvim-tree/nvim-web-devicons',

		cmd = 'FzfLua',

		opts = {
			fzf_colors = {
				border = { 'fg', { 'FzfLuaBorder' } },
				gutter = '-1',
			},
		},

		config = function(_, opts)
			local fzf_lua = require('fzf-lua')
			fzf_lua.setup(opts)

			vim.api.nvim_set_hl(0, 'FzfLuaBorder', { link = 'FloatBorder' })
		end,
	},
	{
		'MagicDuck/grug-far.nvim',

		cmd = {
			'GrugFar',
			'GrugFarWithin',
		},

		keys = {
			{
				'<leader>St',
				function()
					require('grug-far').toggle_instance({})
				end,
				mode = normal_and_visual_modes,
				desc = 'Toggle `grug-far` instance',
			},
			{
				'<leader>Sff',
				function()
					require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })
				end,
				mode = normal_and_visual_modes,
				desc = 'Replace in current file',
			},
			{
				'<leader>Sfw',
				function()
					require('grug-far').open({ prefills = { paths = vim.fn.expand('%'), search = vim.fn.expand('<cword>') } })
				end,
				mode = 'n',
				desc = 'Replace current word in the current file',
			},
			{
				'<leader>Sdd',
				function()
					require('grug-far').open({ prefills = { paths = vim.fn.getcwd() } })
				end,
				mode = normal_and_visual_modes,
				desc = 'Replace in the current directory',
			},
			{
				'<leader>Sdw',
				function()
					require('grug-far').open({ prefills = { paths = vim.fn.getcwd(), search = vim.fn.expand('<cword>') } })
				end,
				mode = 'n',
				desc = 'Replace current word in the current directory',
			},
			{
				'<leader>Sss',
				function()
					require('grug-far').open({ visualSelectionUsage = 'operate-within-range' })
				end,
				mode = 'v',
				desc = 'Replace in current selection',
			},
			{
				'<leader>Ssw',
				function()
					require('grug-far').open({
						visualSelectionUsage = 'operate-within-range',
						prefills = { search = vim.fn.expand('<cword>') },
					})
				end,
				mode = 'v',
				desc = 'Replace current word in the current selection',
			},
		},

		opts = {},

		init = function()
			local set_keymap_name = MYPLUGFUNC.set_keymap_name
			set_keymap_name('<Leader>S', 'Search and replace', normal_and_visual_modes)
			set_keymap_name('<Leader>Sf', 'Replace in the current file', normal_and_visual_modes)
			set_keymap_name('<Leader>Sd', 'Replace in the current directory', normal_and_visual_modes)
			set_keymap_name('<Leader>Ss', 'Replace in the current selection', 'v')
		end,
	},
}
