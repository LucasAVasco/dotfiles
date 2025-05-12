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

return {
	{
		'stevearc/oil.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},

		cmd = 'Oil',

		opts = {
			default_file_explorer = true, -- Replace `Netrw`
			delete_to_trash = true,
		},

		init = function()
			-- Disable 'Netrw'. `oil.nvim` will be the default file manager
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			-- Creates an auto-command to load `oil.nvim` if the user open a directory. `oil.nvim` can not be lazy loaded without this.
			-- `oil.nvim` can open only one directory at the same time
			local nvim_startup_done = false
			local file_explorer_augroup = vim.api.nvim_create_augroup('FileExplorer', { clear = true })

			vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter' }, {
				group = file_explorer_augroup,
				callback = function(arguments)
					-- `oil.nvim` can not open a directory before Neovim ends its start process. Neovim emits a 'VimEnter' event after this
					if arguments.event == 'VimEnter' then
						nvim_startup_done = true
					end

					if not nvim_startup_done then
						return
					end

					-- Only starts `oil.nvim` if opening a directory that exists
					local file = arguments.file
					if vim.fn.isdirectory(file) == 1 then
						-- Removes any auto-command related to the default file explorer. This includes the current auto-command
						vim.api.nvim_del_augroup_by_id(file_explorer_augroup)

						-- Loads `oil.nvim` and opens the file. It only needs to be done once. Once `oil.nvim` is loaded, it will
						-- automatically track the folders the user opens
						require('oil').open(file)
					end
				end,
			})
		end,

		config = function(_, opts)
			require('oil').setup(opts)

			-- Snacks rename. Integrates 'oil.nvim' rename file action with LSP 'workspace/willRenameFiles' method. Copied form
			-- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md
			vim.api.nvim_create_autocmd('User', {
				pattern = 'OilActionsPost',
				callback = function(event)
					if event.data.actions.type == 'move' then
						Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
					end
				end,
			})
		end,
	},
	{
		'nvim-tree/nvim-tree.lua',

		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},

		cmd = {
			'NvimTreeOpen',
			'NvimTreeClose',
			'NvimTreeToggle',
			'NvimTreeFocus',
			'NvimTreeFindFile',
			'NvimTreeFindFileToggle',
		},

		keys = {
			{ '<leader>gfe', '<cmd>NvimTreeFocus<CR>', mode = 'n', desc = 'Open file explorer' },
		},

		opts = {
			sort = {
				sorter = 'case_sensitive',
			},
			view = {
				width = 60,
			},
			renderer = {
				add_trailing = true, -- Append a trailing slash to folder names
				group_empty = true, -- Group empty folders in one group
				highlight_git = 'icon', -- Highlight git attributes
				highlight_diagnostics = 'icon',
				highlight_opened_files = 'name',
				highlight_modified = 'name',

				indent_markers = {
					enable = true,
					icons = {
						corner = '╰',
					},
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
					exclude = { '.git' },
				},
			},

			-- Does not disable `Netrw` in `nvim-tree` configuration. The `oil.nvim` configuration will do it
			hijack_netrw = true,
			disable_netrw = false,
		},

		config = function(_, opts)
			local api = require('nvim-tree.api')

			--- Decorator that does not call the function if the folder is open
			--- Also call the function it the cursor is under a file
			---@param func fun() Lua function that will be called
			---@return fun() decorated_function A Lua function that only calls *func* if the folder is not open
			local function decorator_ignore_open_folder(func)
				return function()
					-- `api.tree.get_node_under_cursor().open` is `true` if the folder is open, `false` if it is closed, and `nil` if it is
					-- not a folder (E.g. It is a file)
					if api.tree.get_node_under_cursor().open then
						return
					end

					func()
				end
			end

			--- Decorator that return to the original window after executing *func*
			---@param func fun() Lua function that will be called.
			---@return fun() decorated_function A Lua function that will return to the original window after executing *func*
			local function decorator_return_to_tree(func)
				return function()
					local current_win_id = vim.fn.win_getid()
					func()
					vim.fn.win_gotoid(current_win_id)
				end
			end

			--- Apply custom keymaps to the `nvim-tree` buffer
			---@param bufnr number Buffer number of the `nvim-tree` buffer
			local function apply_custom_keymaps(bufnr)
				local key_options = MYFUNC.decorator_create_options_table({
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

				-- Does not delete files, only trashes them
				vim.keymap.set('n', 'd', api.fs.trash, key_options('Trash current file or folder'))
				vim.keymap.set('n', 'bd', api.marks.bulk.trash, key_options('Trash all marked nodes'))

				-- Override 'h' and 'l' to improve movement in the tree
				vim.keymap.set('n', 'h', api.node.navigate.parent_close, key_options('Close the current folder'))
				vim.keymap.set('n', 'l', decorator_ignore_open_folder(open_and_return_to_tree), key_options('Open folder or file'))

				-- Custom keymaps
				vim.keymap.set(
					'n',
					'T',
					decorator_return_to_tree(api.node.open.tab_drop),
					key_options('Open file in new tab (if not already opened)')
				)

				vim.keymap.set(
					'n',
					't',
					api.node.open.tab_drop,
					key_options('Go to file (if not already opened, open in new tab) and close the tree')
				)

				vim.keymap.set('n', 'g.', function()
					api.tree.toggle_hidden_filter()
					api.tree.toggle_gitignore_filter()
				end, key_options('Show/hide ignored and hidden files'))
			end

			-- Setup
			opts.on_attach = apply_custom_keymaps
			require('nvim-tree').setup(opts)

			-- Snacks rename. Integrates 'nvim-tree' rename file action with LSP 'workspace/willRenameFiles' method. Based on the
			-- configuration from https://github.com/folke/snacks.nvim/blob/main/docs/rename.md

			local nvim_tree_api_events = require('nvim-tree.api').events

			local last_rename_data = {}

			nvim_tree_api_events.subscribe(nvim_tree_api_events.Event.NodeRenamed, function(rename_data)
				-- Prevents duplication of the call
				if vim.deep_equal(last_rename_data, rename_data) then
					return
				end

				last_rename_data = rename_data
				require('snacks').rename.on_rename_file(rename_data.old_name, rename_data.new_name)
			end)
		end,
	},
}
