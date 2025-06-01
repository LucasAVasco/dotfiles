--[[ autodoc
	====================================================================================================
	Auto-completion commands (Plugin)[cmd]                                  *plugin-completion-commands*

	`LuaSnipEditFiles` Edit the LuaSnip snippets files
]]

return {
	-- {
	--     'nvimtools/none-ls.nvim',
	--     main = 'null-ls',
	--     dependencies = {
	--         'nvim-lua/plenary.nvim'
	--     },
	--
	--     config = function()
	--         null_ls = require('null-ls')
	--
	--         null_ls.setup({
	--             sources = {
	--                 -- E.null_ls.builtins.formatting.stylua,
	--             }
	--         })
	--     end
	-- },
	{
		'L3MON4D3/LuaSnip',
		version = 'v2.*',

		dependencies = {
			'rafamadriz/friendly-snippets',
		},

		build = 'make install_jsregexp', -- Required to use variable/placeholder transformations in the snippets

		cmd = {
			'LuaSnipEditFiles',
			'LuaSnipListAvailable',
			'LuaSnipUnlinkCurrent',
		},

		lazy = true, -- Will be loaded by `nvim-cmp`

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
		event = 'InsertEnter',

		dependencies = {
			'hrsh7th/nvim-cmp',
		},

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

			-- Auto-pairs integration with cmp-nvim
			require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
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

		-- Only enabled if editing a Lua file and the user is inside a directory owned by Neovim
		ft = 'lua',
		enabled = function()
			-- Current directory. The comparison that defines whether the current directory belongs to Neovim checks whether the given
			-- directory path is a sub-string of the current directory path. Adding a trailing slash allows the user to optionally provide a
			-- path with a trailing slash. Do not use the `getcwd()` function because this function follows symbolic links. This may break
			-- my configuration that manages my dot files with `stow`
			local current_dir = vim.env.PWD .. '/'

			---Check is the current directory is inside a provided folder
			---The tilde (~) is NOT expanded to the user home directory. You need to manually do it if necessary
			---@param top_dir string Path to the folder that may hold the current directory
			local function current_dir_is_inside_folder(top_dir)
				return current_dir:find(top_dir, 1, true) ~= nil
			end

			return current_dir_is_inside_folder(MYPATHS.config)
				or current_dir_is_inside_folder(MYPATHS.data)
				or current_dir_is_inside_folder(MYPATHS.dev)
		end,

		opts = {
			library = {
				{ path = 'luvit-meta/library', words = { 'vim.loop', 'vim.uv', 'uv' } },
			},
		},
	},
	{
		'hrsh7th/nvim-cmp',

		event = { 'InsertEnter', 'CmdlineEnter' },

		dependencies = {
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-cmdline',

			-- LSP
			'hrsh7th/cmp-nvim-lsp',
			'onsails/lspkind.nvim',
			'folke/lazydev.nvim', -- LuaLS configuration to edit Neovim configuration files

			-- Snippets
			'saadparwaiz1/cmp_luasnip',
			'L3MON4D3/LuaSnip',
		},

		config = function()
			local cmp = require('cmp')
			local cmp_buffer = require('cmp_buffer')
			local lspkind = require('lspkind')
			local luasnip = require('luasnip')

			-- Defines the name that will be placed with the completion based by its source
			local source_name2item_menu = {
				path = ' Path',
				buffer = ' Buffer',
				nvim_lsp = ' LSP',
				luasnip = '󰽥 LuaSnip',
				cmdline = '󱞪 CmdLine',
				lazydev = ' LazyDev',
				orgmode = ' OrgMode',
				['vim-dadbod-completion'] = ' Database',
			}

			--- Configures the highlighting groups that will be used in the suggestions menu
			local function update_cmp_hl()
				-- Get all highlight groups and apply the customization to the ones that will appear in the item kind.
				-- They start with `CmpItemKind`
				local all_hl_groups = vim.api.nvim_get_hl(0, {})

				for hl_group_name, _ in pairs(all_hl_groups) do
					if string.find(hl_group_name, 'CmpItemKind', 1, true) then
						local new_hl = MYFUNC.get_hl_definition(hl_group_name)
						new_hl.standout = true -- Swap background and foreground colors
						new_hl.bold = true

						-- The format returned by `get_hl_definition` is the same as the received by `nvim_set_hl`, but LuasLS does not
						-- recognize it. So I am disabling the diagnostic to the next line
						---@diagnostic disable-next-line: param-type-mismatch
						vim.api.nvim_set_hl(0, hl_group_name, new_hl)
					end
				end
			end

			-- Applies the custom highlighting to all color schemes
			vim.api.nvim_create_autocmd('ColorScheme', {
				pattern = '*',
				callback = update_cmp_hl,
			})

			update_cmp_hl()

			--- Closes the completion and runs the fallback
			--- It is different from `cmp.close` that runs the fallback only if the completion is closed. This function do the both at the
			--- same time.
			---@param fallback fun() Fallback function
			local function close_completion(fallback)
				cmp.close()
				fallback()
			end

			---Equivalent to the `cmp.visible()` function, but runs asynchronously.
			---@return boolean
			local function cmp_async_visible()
				return cmp.core.view:visible() and vim.fn.pumvisible()
			end

			-- CMP configuration
			cmp.setup({
				window = {
					documentation = cmp.config.window.bordered(),
				},

				enabled = function()
					-- Disables CMP when running a macro. The default CMP configuration also disables it when tipping a macro, but I
					-- want the suggestions in this case. Only remember to not trigger the suggestions when tipping a macro or the behavior
					-- will be unexpected.
					local enabled = vim.fn.reg_executing() == ''

					-- The default CMP configuration also disables it when in a prompt
					enabled = enabled and vim.bo.buftype ~= 'prompt'

					return enabled
				end,

				sources = {
					{
						name = 'path',
						priority = 50,
						option = {
							---Return the directory that `cmp-path` will use when inserting relative paths
							---@param cmp_data table<string, any> Data provided by `cmp-path`
							---@return string current_working_directory
							get_cwd = function(cmp_data)
								local buffer_nr = cmp_data.context.bufnr
								local buffer_file_type = vim.bo[buffer_nr].filetype
								local buffer_path = vim.api.nvim_buf_get_name(buffer_nr)
								local base_dir = vim.fn.fnamemodify(buffer_path, ':p:h') -- Current working directory

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
								if buffer_file_type == 'gitcommit' then
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
					{
						name = 'buffer',
						get_bufnrs = function()
							--- Filter to get the buffers that will be used in this suggestions
							---@param buf_nr number Buffer number
							---@return boolean can_suggestions if the buffer should be used in the suggestions (true or false)
							local function filter_buffers(buf_nr)
								-- Only uses normal buffers
								if vim.bo[buf_nr].buftype ~= '' then
									return false
								end

								-- Does not use large files
								local buffer_size = vim.api.nvim_buf_get_offset(buf_nr, vim.api.nvim_buf_line_count(buf_nr))
								if buffer_size > 10 * 1024 * 1024 then
									return false
								end

								return true
							end

							-- Gets all buffers and filter them before send to CMP
							local buffers = vim.api.nvim_list_bufs()
							return vim.tbl_filter(filter_buffers, buffers)
						end,
					},
					{ name = 'nvim_lsp', priority = 30 },
					{ name = 'luasnip' },

					-- Specific to some filetypes
					{ name = 'lazydev' }, -- Suggestions to `require()`
					{ name = 'orgmode', priority = 20 },
					{ name = 'vim-dadbod-completion', priority = 20 },
				},

				sorting = {
					priority_weight = 1,

					comparators = {
						cmp.config.compare.recently_used,
						cmp.config.compare.locality,
						cmp.config.compare.score,
					},
				},

				mapping = {
					-- Navigate thought the suggestions
					['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 6 }),
					['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select, count = 6 }),

					['<Tab>'] = function(fallback)
						if cmp_async_visible() and cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						elseif luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end,

					['<S-Tab>'] = function(fallback)
						if cmp_async_visible() and cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end,

					['<A-Tab>'] = function(fallback)
						if luasnip.choice_active() then -- Shows the choice selector if in insert mode and inside a choice node
							require('luasnip.extras.select_choice')()
						else
							fallback()
						end
					end,

					-- Accept the suggestions or snippet entry
					['<CR>'] = function(fallback)
						if cmp_async_visible() and cmp.get_selected_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
						elseif luasnip.choice_active() then -- Shows the choice selector if in insert mode and inside a choice node
							require('luasnip.extras.select_choice')()
						else
							fallback()
						end
					end,

					['<S-CR>'] = function(fallback)
						if cmp_async_visible() and cmp.visible() then
							cmp.close()
						else
							fallback()
						end
					end,

					['<C-Space>'] = cmp.mapping.complete(),

					-- Expand the snippet entry
					['<A-CR>'] = function(fallback)
						if luasnip.expandable() then
							luasnip.expand({})
						else
							fallback()
						end
					end,

					-- Abort the completion
					['<A-q>'] = cmp.mapping.close(),
					['<A-a>'] = cmp.mapping.close(),
					['<Left>'] = close_completion,
					['<Right>'] = close_completion,

					-- Docs
					['<A-d>'] = cmp.mapping.scroll_docs(6),
					['<A-u>'] = cmp.mapping.scroll_docs(-6),
				},

				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- Custom formatting to the suggestions
				formatting = {
					expandable_indicator = true,

					fields = { 'kind', 'abbr', 'menu' },

					format = function(entry, vim_completed_item)
						local kind = lspkind.presets.default[vim_completed_item.kind] -- Convert the kind with lspkind
						vim_completed_item.kind = ' ' .. (kind or '?') .. ' '
						vim_completed_item.menu = source_name2item_menu[entry.source.name] -- Add the source name to the menu

						return vim_completed_item
					end,
				},
			})

			-- Completions for search modes
			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'path' },
					{ name = 'buffer' },
				},
			})

			-- Completions for command mode
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' },
					{ name = 'cmdline' },
				}),
			})
		end,
	},
}
