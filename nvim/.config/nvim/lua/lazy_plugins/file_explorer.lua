--[[ autodoc
	====================================================================================================
	File explorer mappings (Plugin)[maps]                                    *plugin-file-explorer-maps*

	`gf` Open NvimTree.

	`g?` Show the keymaps.

	Custom keymaps~

	`T` Open in new tab (if not already in a tab).
	`t` Open in new tab (if not already in a tab) and focus.

	Useful keys~

	`I` Show/hide untracked files (git). They are hidden by default.
	`H` Show/hide hidden files (dotfiles). They are hidden by default.
	`C` Show/hide files without git status.

	Bookmarks~

	`m` Bookmark current file.
	`M` Show/hide the bookmaked files.

	Filter files~

	`f` Enable regex (vimscript) filter. Only show files that match the regex.
	`F` Disable regex filter.
]]


--- Decorator that return to the original window after executing *func*
-- @param func Lua function that will be called.
-- @return A Lua function that will return to the original window after executing *func*
local function decorator_return_to_tree(func)
	return function()
		local current_win_id = vim.fn.win_getid()
		func()
		vim.fn.win_gotoid(current_win_id)
	end
end


--- Apply custom keymaps to the nvim-tree buffer
-- @param bufnr Buffer number of the nvim-tree buffer
local function apply_custom_keymaps(bufnr)
	local api = require('nvim-tree.api')

	local key_options = myfunc.decorator_create_options_table({
		buffer = bufnr,
		nowait = true,
		noremap = true,
		silent = true,
	})

	-- Default keymaps
	api.config.mappings.default_on_attach(bufnr)

	-- Override default open keymap to return to the tree after open the file
	local open_and_return_to_tree = decorator_return_to_tree(api.node.open.edit)

	for _, key in ipairs({ '<CR>', 'o', '<2-LeftMouse>' }) do
		vim.keymap.set('n', key, open_and_return_to_tree, key_options('Open to edit'))
	end

	-- Custom keymaps
	vim.keymap.set('n', 'T', decorator_return_to_tree(api.node.open.tab_drop), key_options('Open file in new tab (if not already opened)'))
	vim.keymap.set('n', 't', api.node.open.tab_drop, key_options('Go to file (if not already opened, open in new tab) and close the tree'))
end


return {
	{
		name = 'disable-netrw',
		lazy = false,

		-- If *dir* is provided, the plugin will be load from a local directory instead from the internet (with git).
		-- To this plugin, the *dir* is pointing to a folder without a plugin installed. This makes creates a plugin that
		-- does not load any files, but act as an real plugin and executes the *init* function.
		dir = '~/.config/nvim/empty_plugin/',

		init = function()
			-- Disable Netrw (recommended by nvim.tree)
			vim.g.loaded_netrw       = 1
			vim.g.loaded_netrwPlugin = 1
		end
	},

	{
		'nvim-tree/nvim-tree.lua',

		dependencies = {
			'nvim-tree/nvim-web-devicons',
			'disable-netrw',
		},

		cmd = { 'NvimTreeOpen', 'NvimTreeClose', 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile', 'NvimTreeFindFileToggle' },

		keys = {
			{ 'gf', '<cmd>NvimTreeFocus<CR>', mode = 'n' },
		},

		opts = {
			on_attach = apply_custom_keymaps,

			sort = {
				sorter = 'case_sensitive',
			},
			view = {
				width = 60,
			},
			renderer = {
				add_trailing = true,     -- Append a trailing slash to folder names
				group_empty = true,      -- Group empty folders in one group
				highlight_git = 'icon',  -- Highlight git attributes
				highlight_diagnostics = 'icon',
				highlight_opened_files = 'name',
				highlight_modified = 'name',

				indent_markers = {
					enable = true,
					icons = {
						corner = "╰",
					}
				},
			},

			git = {
				enable = true,
			},

			diagnostics = {
				enable = true,
				show_on_dirs = true,
			},

			modified = {
				enable = true,
			},

			filters = {
				dotfiles = true,
			},

			actions = {
				expand_all = {
					-- Do not expand this folders automatically
					exclude = { '.git' }
				}
			}
		}
	}
}
