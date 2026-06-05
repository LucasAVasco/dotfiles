--[[ autodoc
	====================================================================================================
	Auto-completion commands (Plugin)[cmd]                                  *plugin-completion-commands*

	`LuaSnipEditFiles` Edit the LuaSnip snippets files
]]

local blink_cmp_score_offset = {
	path = 100,
	lsp = 90,
	buffer = 80,
}

return {
	{
		'L3MON4D3/LuaSnip',
		version = 'v2.*',

		dependencies = {
			'rafamadriz/friendly-snippets',
		},

		build = 'make install_jsregexp', -- Required to use variable/placeholder transformations in the snippets

		cond = MYVAR.not_in_vscode,

		cmd = {
			'LuaSnipEditFiles',
			'LuaSnipListAvailable',
			'LuaSnipUnlinkCurrent',
		},

		lazy = true, -- Will be loaded by `blink.cmp`

		opts = {
			---Defines the file types used to load snippets for the current buffer.
			---@return string[] file_types Load snippets to these file types in the current buffer.
			ft_func = function()
				local file_types = vim.split(vim.bo.filetype, '.', { plain = true })

				for _, file_type in ipairs(file_types) do
					if file_type == 'helm' then
						table.insert(file_types, 'yaml')
					end
				end

				return file_types
			end,

			---Defines which file types belongs to a buffer. Used by the 'lazy_load' function to know what snippets to lazy load.
			---@param buffer_num integer
			---@return string[] file_types
			load_ft_func = function(buffer_num)
				local full_file_type = vim.api.nvim_get_option_value('filetype', { buf = buffer_num })
				local file_types = vim.split(full_file_type, '.', { plain = true })

				for _, file_type in ipairs(file_types) do
					if file_type == 'helm' then
						table.insert(file_types, 'yaml')
					end
				end

				return file_types
			end,
		},

		config = function(_, opts)
			require('luasnip').setup(opts)

			-- Command to easy edit the snippets files
			vim.api.nvim_create_user_command('LuaSnipEditFiles', function()
				require('luasnip.loaders').edit_snippet_files()
			end, {})

			-- Disables the snippet files reloading after any modification. This feature throws errors messages every time the user saves an
			-- incomplete snippet file
			local fs_event_providers = {
				autocmd = false,
				libuv = false,
			}

			-- Load default snippets (also load friendly-snippets)
			-- Not all friendly-snippets are loaded because they are specific to some frameworks
			-- They can be found here: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets/frameworks
			-- E.g: To load Rails snippets, use:
			-- require('luasnip').filetype_extend('ruby', {'rails'})
			require('luasnip.loaders.from_vscode').lazy_load({ fs_event_providers = fs_event_providers })

			-- My snippets
			require('luasnip.loaders.from_vscode').lazy_load({
				paths = { '~/.config/nvim/vscode_snippets' },
				fs_event_providers = fs_event_providers,
			})
			require('luasnip.loaders.from_lua').lazy_load({
				paths = { '~/.config/nvim/lua_snippets' },
				fs_event_providers = fs_event_providers,
			})
		end,
	},
	{
		'windwp/nvim-autopairs',

		cond = MYVAR.not_in_vscode, -- Already provided by VSCode

		event = 'InsertEnter',

		opts = {
			disable_filetype = { 'TelescopePrompt', 'NvimTree' },
			fast_wrap = {
				map = '<A-r>',
			},
		},

		config = function(_, opts)
			local npairs = require('nvim-autopairs')
			local Rule = require('nvim-autopairs.rule')

			npairs.setup(opts)

			npairs.add_rules({
				Rule('`', '`'), -- Crasis pair (like the used in Markdown)

				Rule('"""', '"""'), -- Triple double quotes string (like the Python docstrings)
				Rule("'''", "'''"), -- Triple quotes string (like the Python docstrings)

				-- Triple crasis pair (like the used in Markdown), the right pair just completest the right pair created by
				-- the 'crasis pair' rule. Because of this, there are only one crasis in the right pair
				Rule('```', '`'),
			})
		end,
	},
	{
		'windwp/nvim-ts-autotag',

		opts = {},

		ft = {
			-- Copied from https://github.com/windwp/nvim-ts-autotag
			'astro',
			'glimmer',
			'handlebars',
			'html',
			'javascript',
			'jsx',
			'markdown',
			'php',
			'rescript',
			'svelte',
			'tsx',
			'twig',
			'typescript',
			'vue',
			'xml',
		},
	},
	{
		'folke/lazydev.nvim',

		dependencies = {
			'Bilal2453/luvit-meta', -- Support to 'vim.loop'
		},

		cond = MYVAR.not_in_vscode,

		-- Only enabled if editing a Lua file and the user is inside a directory owned by Neovim
		ft = 'lua',

		opts = {
			library = {
				{ path = 'luvit-meta/library', words = { 'vim.loop', 'vim.uv', 'uv' } },
				{ path = MYPATHS.config },
			},

			enabled = function()
				-- Respects the `lazydev_enabled` global variable
				if vim.g.lazydev_enabled ~= nil then
					return vim.g.lazydev_enabled
				end

				-- Current directory. The comparison that defines whether the current directory belongs to Neovim checks whether the given
				-- directory path is a sub-string of the current directory path. Adding a trailing slash allows the user to optionally provide a
				-- path with a trailing slash. Do not use the `getcwd()` function because this function follows symbolic links. This may break
				-- my configuration that manages my dot files with `stow`
				---@type string
				local current_dir = vim.env.PWD .. '/'

				---Check is the current directory is inside a provided folder
				---The tilde (~) is NOT expanded to the user home directory. You need to manually do it if necessary
				---@param top_dir string Path to the folder that may hold the current directory
				local function current_dir_is_inside_folder(top_dir)
					return current_dir:find(top_dir, 1, true) ~= nil
				end

				return current_dir_is_inside_folder(MYPATHS.config_folder_rel_to_home)
					or current_dir_is_inside_folder(MYPATHS.data)
					or current_dir_is_inside_folder(MYPATHS.dev)
					or current_dir_is_inside_folder('.nvim-proj')
			end,
		},
	},
	{
		'saghen/blink.cmp',
		version = '1.*',
		dependencies = {
			'onsails/lspkind.nvim',
			'L3MON4D3/LuaSnip',
			'rafamadriz/friendly-snippets',
			{
				'mikavilpas/blink-ripgrep.nvim',
				version = '*',
			},
		},

		cmd = { 'BlinkCmp' },
		event = { 'InsertEnter', 'CmdlineEnter' },

		---@module 'blink-cmp'
		---@see defaults ~/.local/share/nvim/lazy/blink.cmp/lua/blink/cmp/config/init.lua
		---@type blink.cmp.Config
		opts = {
			snippets = { preset = 'luasnip' },
			signature = { enabled = false }, -- I use 'noice.nvim' instead

			completion = {
				list = {
					selection = {
						preselect = false,
						auto_insert = false,
					},
				},

				menu = {
					border = 'rounded',
					max_height = 20,

					draw = {
						treesitter = { 'lsp' },
						columns = { { 'kind_icon', 'label', gap = 2 }, { 'source_name' } },
					},
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,

					window = {
						border = 'rounded',
					},
				},
			},

			sources = {
				-- Enabled sources

				default = {
					-- Default sources
					'path',
					'lsp',
					'snippets',
					'buffer',

					-- Additional sources
					'ripgrep',
				},

				per_filetype = {
					lua = { inherit_defaults = true, 'lazydev' },
					org = { inherit_defaults = true, 'orgmode' },
				},

				-- Source providers configuration

				providers = {
					cmdline = {
						name = '󱞪 CmdLine',
						score_offset = 200,
					},

					path = {
						name = ' Path',
						score_offset = blink_cmp_score_offset.path,

						opts = {
							show_hidden_files_by_default = true,

							---Return the directory that `blink.cmp` will use when inserting relative paths
							---@param context blink.cmp.Context Data provided by `blink.cmp`
							---@return string current_working_directory
							get_cwd = function(context)
								local buffer_nr = context.bufnr
								local buffer_file_type = vim.bo[buffer_nr].filetype
								local buffer_path = vim.api.nvim_buf_get_name(buffer_nr)
								local base_dir = vim.fn.fnamemodify(buffer_path, ':p:h') -- Current working directory

								-- Use the global variable
								if vim.g.cmp_pth_cwd then
									return vim.g.cmp_pth_cwd
								end

								---Splits the `base_dir` at the provided index an use the first division as the new `base_dir`.
								---@param index number? Split the `base_dir` at this index. If `nil` aborts the operation.
								---@return boolean split If the `base_dir` has been split.
								local function split_base_dir_at_index(index)
									if index ~= nil then
										base_dir = string.sub(base_dir, 0, index)
										return true
									end

									return false
								end

								-- Use the git repository root directory when editing the '.git/COMMIT_EDITMSG' file
								if vim.env.EDITING_COMMAND_LINE then
									return vim.env.PWD
								elseif buffer_file_type == 'gitcommit' then
									base_dir = vim.fn.fnamemodify(base_dir, ':h')
								elseif buffer_file_type == 'yaml' then
									-- Use the root directory of the GitHub workflow
									if split_base_dir_at_index(string.find(base_dir, '/.github/workflows', 0, true)) then
										return base_dir
									end
								end

								return base_dir
							end,
						},
					},

					lsp = {
						name = ' LSP',
						score_offset = blink_cmp_score_offset.lsp,

						fallbacks = {}, -- Always show the buffer source when there is no fallback
					},

					snippets = {
						name = '󰽥 Snippets',
						score_offset = blink_cmp_score_offset.buffer,
					},

					buffer = {
						name = ' Buffer',
						score_offset = blink_cmp_score_offset.buffer,
					},

					-- Additional sources

					ripgrep = {
						name = ' Ripgrep',
						score_offset = blink_cmp_score_offset.buffer - 5,
						module = 'blink-ripgrep',
						async = true,

						---@module "blink-ripgrep"
						---@type blink-ripgrep.Options
						opts = {},
					},

					orgmode = {
						name = ' OrgMode',
						module = 'orgmode.org.autocompletion.blink',
						score_offset = blink_cmp_score_offset.lsp,
					},

					lazydev = {
						name = ' LazyDev',
						module = 'lazydev.integrations.blink',
						score_offset = blink_cmp_score_offset.path + 100, -- High priority then 'lsp' and 'path'
					},
				},
			},

			cmdline = {
				keymap = {
					['<Right>'] = false,
					['<Left>'] = false,
				},

				completion = {
					menu = {
						-- Always show the completion menu
						auto_show = true,
					},
				},
			},

			keymap = {
				preset = 'enter',

				['<down>'] = {
					function(cmp)
						return cmp.select_next({ count = 6 })
					end,
					'fallback',
				},

				['<up>'] = {
					function(cmp)
						return cmp.select_prev({ count = 6 })
					end,
					'fallback',
				},

				-- Abort the completion
				['<S-CR>'] = { 'cancel', 'fallback' },
				['<A-q>'] = { 'hide', 'fallback' },
				['<A-a>'] = { 'hide', 'fallback' },
				['<Left>'] = {
					-- Hide and run fallback
					function(cmp)
						cmp:hide()
					end,
					'fallback',
				},
				['<Right>'] = {
					-- Hide and run fallback
					function(cmp)
						cmp:hide()
					end,
					'fallback',
				},

				-- Docs
				['<A-u>'] = { 'scroll_documentation_up', 'fallback' },
				['<A-d>'] = { 'scroll_documentation_down', 'fallback' },
			},

			appearance = {
				-- I do not like the default appearance of the completion menu configured by Kanagawa. The following configuration makes
				-- 'blink.cmp' looks like 'nvim-cmp'
				use_nvim_cmp_as_default = true,
			},
		},

		opts_extend = { 'sources.default' },

		---@param opts blink.cmp.Config
		config = function(_, opts)
			local luasnip = require('luasnip')

			---Configure the highlighting groups that are used in the suggestions menu
			local function update_hl()
				-- Get all highlight groups and apply the customization to the ones that appears in the item kind.
				-- They start with `BlinkCmpKind`
				local all_hl_groups = vim.api.nvim_get_hl(0, {})

				for hl_group_name, _ in pairs(all_hl_groups) do
					if string.find(hl_group_name, 'BlinkCmpKind', 1, true) then
						local new_hl = MYFUNC.get_hl_definition(hl_group_name)
						new_hl.standout = true -- Swap background and foreground colors
						new_hl.bold = true

						-- The format returned by `get_hl_definition` is the same as the received by `nvim_set_hl`, but LuasLS does not
						-- recognize it. So I am disabling the diagnostic to the next line
						---@diagnostic disable-next-line: param-type-mismatch
						vim.api.nvim_set_hl(0, hl_group_name, new_hl)
					end
				end

				-- Customize the highlight groups that appears in the completion menu
				vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { link = 'Float' })
				vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { link = 'FloatBorder' })
			end

			-- Applies the custom highlighting to all color schemes
			vim.api.nvim_create_autocmd('ColorScheme', {
				pattern = '*',
				callback = update_hl,
			})

			update_hl()

			-- Format the kind icon with the symbols from 'lspkind'
			MYFUNC.tbl_set(opts, 'completion.menu.draw.components.kind_icon', {})
			local lsp_symbol_map = require('lspkind').symbol_map
			opts.completion.menu.draw.components.kind_icon.text = function(ctx)
				return ' ' .. (lsp_symbol_map[ctx.kind] or '?') .. ' '
			end

			---Jump to the snippet entry. Do not expand the snippet
			---@param direction integer 1 for forward, -1 for backward
			local function jump_snippet(direction)
				if not luasnip.jumpable(direction) then
					return false
				end

				vim.schedule(function()
					luasnip.jump(direction)
				end)

				return true
			end

			---Try to open the choice selector. Do nothing if it is not possible
			---@return boolean opened True if the choice selector was opened
			---@param cmp blink.cmp.API
			local function try_select_choice(cmp)
				if cmp.snippet_active() and luasnip.choice_active() then
					-- The choice selector must be opened in the next event loop because of a textlock
					vim.schedule(function()
						-- Choice may not be active in the next event loop. Need to check
						if luasnip.choice_active() then
							require('luasnip.extras.select_choice')()
						end
					end)
					return true
				end

				return false
			end

			-- Navigate thought the suggestions
			opts.keymap['<Tab>'] = {
				'select_next',
				function(cmp)
					if jump_snippet(1) then
						try_select_choice(cmp)
						return true
					end
				end,
				'fallback',
			}

			opts.keymap['<S-Tab>'] = {
				'select_prev',
				function(cmp)
					if jump_snippet(-1) then
						try_select_choice(cmp)
						return true
					end
				end,
				'fallback',
			}

			opts.keymap['<C-Tab>'] = {
				function(cmp)
					return try_select_choice(cmp)
				end,
				'fallback',
			}

			-- Accept the suggestions or snippet entry
			opts.keymap['<CR>'] = {
				---Try to accept the current suggestion
				---@param cmp blink.cmp.API
				---@return boolean|nil
				function(cmp)
					if not cmp:is_active() then
						return
					end

					if cmp.accept() then
						-- Select the choice after the snippet is expanded
						vim.schedule(function()
							try_select_choice(cmp)
						end)

						return true
					end
				end,

				---Try to handle auto-pairing
				---@return string
				function()
					return require('nvim-autopairs').autopairs_cr()
				end,

				'fallback',
			}

			-- Expand the snippet entry
			opts.keymap['<A-CR>'] = {
				function()
					if luasnip.expandable() then
						vim.schedule(luasnip.expand)
						return true
					end
				end,
				'fallback',
			}

			-- Setup
			require('blink.cmp').setup(opts)
		end,
	},
}
