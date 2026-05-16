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

---Decorate a function to return to NeoTree after executing it. Any error caused by the function will be ignored
---@param func fun(state: neotree.StateWithTree)
---@return fun(state: neotree.StateWithTree)
local function decorate_return_to_neo_tree(func)
	return function(state)
		pcall(func, state)
		vim.schedule(function()
			vim.cmd('Neotree focus position=float')
		end)
	end
end

return {
	{
		'antosha417/nvim-lsp-file-operations',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-neo-tree/neo-tree.nvim',
		},
		lazy = true, -- Already loaded by my file explorer configuration
		config = function()
			require('lsp-file-operations').setup()
		end,
	},
	{
		'stevearc/oil.nvim',
		dependencies = {
			'nvim-tree/nvim-web-devicons',
		},

		cond = MYVAR.not_in_vscode,

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
		'nvim-neo-tree/neo-tree.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'MunifTanjim/nui.nvim',
			'nvim-tree/nvim-web-devicons',
		},

		lazy = true,
		cond = MYVAR.not_in_vscode,
		cmd = 'Neotree',

		keys = {
			{ '<leader>gfe', '<cmd>Neotree focus position=float<CR>', mode = 'n', desc = 'Open file explorer' },
		},

		---@module 'neo-tree.types.config'
		---@see defaults ~/.local/share/nvim/lazy/neo-tree.nvim/lua/neo-tree/defaults.lua
		---@type neotree.Config
		opts = {
			close_if_last_window = true,
			open_files_do_not_replace_types = MYVAR.utilities_ft,

			source_selector = {
				winbar = true,
				show_scrolled_off_parent_node = true,
				content_layout = 'center',
				truncation_character = '…',
			},

			trash = {
				-- Use a internal trash implementation that supports undo and the freedesktop standard
				command = function(...)
					require('neo-tree.trash.freedesktop').generate_trashfunc(...)
				end,
			},

			default_component_configs = {
				name = {
					trailing_slash = true,
					highlight_opened_files = true,
					use_git_status_colors = false,
				},

				indent = {
					with_expanders = true,
					last_indent_marker = '╰',
				},
			},

			window = {
				-- Floating window configuration
				popup = {
					size = {
						width = '60%',
					},
				},

				mappings = {
					-- File operations
					['A'] = 'rename',

					-- Movement
					['<left>'] = 'close_node',
					['h'] = 'close_node',
					['<right>'] = 'open_dir',
					['l'] = 'open_dir',
					['<A-[>'] = 'prev_source',
					['<A-]>'] = 'next_source',

					-- Open and return
					['<cr>'] = 'open_and_return',
					['<2-LeftMouse>'] = 'open_and_return',
					['t'] = 'open_tabnew_and_return',

					-- New file or directory
					['o'] = {
						'add',
						config = {
							show_path = 'none',
						},
					},
					['O'] = {
						'add',
						config = {
							show_path = 'none',
						},
					},
				},
			},

			filesystem = {
				use_libuv_file_watcher = true,

				-- Do not disable `Netrw` in `neo-tree` configuration. The `oil.nvim` configuration will do it
				hijack_netrw_behavior = 'disabled',

				window = {
					mappings = {
						['g.'] = 'toggle_hidden',

						-- Trash actions
						['d'] = 'noop', -- The default 'delete' action can not be recovered. Disabling it
						['dd'] = 'trash',

						-- Rename the 'o*' actions to 'S*' (same used by 'Vifm' to sort files)
						['S'] = { 'show_help', nowait = false, config = { title = 'Sort (order) by', prefix_key = 'S' } },
						['Sc'] = { 'order_by_created', nowait = false },
						['Sd'] = { 'order_by_diagnostics', nowait = false },
						['Sg'] = { 'order_by_git_status', nowait = false },
						['Sm'] = { 'order_by_modified', nowait = false },
						['Sn'] = { 'order_by_name', nowait = false },
						['Ss'] = { 'order_by_size', nowait = false },
						['St'] = { 'order_by_type', nowait = false },

						['oc'] = 'noop',
						['od'] = 'noop',
						['og'] = 'noop',
						['om'] = 'noop',
						['on'] = 'noop',
						['os'] = 'noop',
						['ot'] = 'noop',
					},
				},
			},

			git_status = {
				window = {
					mappings = {
						-- Trash actions
						['d'] = 'noop', -- The default 'delete' action can not be recovered. Disabling it
						['dd'] = 'trash',
					},
				},
			},

			commands = {
				open_and_return = decorate_return_to_neo_tree(function(state)
					require('neo-tree.sources.filesystem.commands').open(state)
				end),

				open_tabnew_and_return = decorate_return_to_neo_tree(function(state)
					require('neo-tree.sources.filesystem.commands').open_tabnew(state)
				end),

				open_dir = function(state)
					---@module 'nui.tree'

					local success, node = pcall(state.tree.get_node, state.tree)
					if not success or not node then
						return
					end

					if node.type == 'directory' and not node:is_expanded() then
						require('neo-tree.sources.filesystem.commands').open(state)
					end
				end,
			},

			-- Appearance

			popup_border_style = 'rounded',
			use_popups_for_input = true,
		},

		config = function(_, opts)
			require('neo-tree').setup(opts)
			require('lsp-file-operations')
		end,
	},
}
