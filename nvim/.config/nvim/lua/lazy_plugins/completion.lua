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
			'rafamadriz/friendly-snippets'
		},

		build = 'make install_jsregexp',  -- Required to use variable/placeholder transformations in the snippets

		config = function()
			-- Command to easy edit the snippets files
			vim.api.nvim_create_user_command('LuaSnipEditFiles', function()
				require("luasnip.loaders").edit_snippet_files()
			end, {})

			-- Load default snippets (also load friendly-snippets)
			-- Not all friendly-snippets are loaded because they are specific to some frameworks
			-- They can be found here: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets/frameworks
			-- E.g: To load Rails snippets, use:
			-- require('luasnip').filetype_extend('ruby', {'rails'})
			require('luasnip.loaders.from_vscode').lazy_load()

			-- My snippets
			require('luasnip.loaders.from_vscode').lazy_load({ paths = {'~/.config/nvim/vscode_snippets'} })
			require('luasnip.loaders.from_lua').lazy_load({ paths = {'~/.config/nvim/lua_snippets'} })
		end
	},
	{
		'windwp/nvim-autopairs',
		event = 'InsertEnter',

		dependencies = {
			'hrsh7th/nvim-cmp',
		},

		opts = {
			disable_filetype = { 'TelescopePrompt', 'NvimTree' },
			fast_wrap = {},  -- Required to enable `fast_wrap`
		},

		config = function(_, opts)
			local npairs = require('nvim-autopairs')
			local Rule = require('nvim-autopairs.rule')

			npairs.setup(opts)

			npairs.add_rules({
				Rule("`", "`"),  -- Crasis pair (like the used in Markdown)

				Rule('"""', '"""'),  -- Triple double quotes string (like the Python docstrings)
				Rule("'''", "'''"),  -- Triple quotes string (like the Python docstrings)

				-- Triple crasis pair (like the used in Markdown), the right pair just completest the right pair created by
				-- the 'crasis pair' rule. Because of this, there are only one crasis in the right pair
				Rule("```", "`"),
			})

			-- Auto-pairs integration with cmp-nvim
			require('cmp').event:on(
				'confirm_done',
				require('nvim-autopairs.completion.cmp').on_confirm_done()
			)
		end,
	},
	{
		'folke/lazydev.nvim',

		dependencies = {
			'Bilal2453/luvit-meta',  -- Support to 'vim.loop'
		},

		-- Only enabled if editing a Lua file and the user is inside a directory owned by Neovim
		ft = 'lua',
		enabled=function()
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

			return current_dir_is_inside_folder(MYPATHS.config) or current_dir_is_inside_folder(MYPATHS.data) or
				current_dir_is_inside_folder(MYPATHS.dev)
		end,

		opts = {
			library = {
				{ path = 'luvit-meta/library', words = { 'vim.loop', 'vim.uv', 'uv' }},
			}
		}
	},
	{
		'hrsh7th/nvim-cmp',

		dependencies = {
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-cmdline',

			-- LSP
			'hrsh7th/cmp-nvim-lsp',
			'onsails/lspkind.nvim',
			'folke/lazydev.nvim',  -- LuaLS configuration to edit Neovim configuration files

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
			}

			--- Configures the highlighting groups that will be used in the suggestions menu
			local function update_cmp_hl()
				-- Get all highlight groups and apply the customization to the ones that will appear in the item kind.
				-- They start with `CmpItemKind`
				local all_hl_groups = vim.api.nvim_get_hl(0, {})

				for hl_group_name, _ in pairs(all_hl_groups) do
					if string.find(hl_group_name, 'CmpItemKind', 1, true) then
						local new_hl = MYFUNC.get_hl_definition(hl_group_name)
						new_hl.standout = true  -- Swap background and foreground colors
						new_hl.bold = true

						-- The format returned by `get_hl_definition` is the same as the received by `nvim_set_hl`, but LuasLS does not
						-- recognize it. So I am disabling the diagnostic to the next line
						---@diagnostic disable-next-line: param-type-mismatch
						vim.api.nvim_set_hl(0, hl_group_name, new_hl )
					end
				end
			end

			-- Applies the custom highlighting to all color schemes
			vim.api.nvim_create_autocmd('ColorScheme', {
				pattern = '*', callback = update_cmp_hl
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

			-- CMP configuration
			cmp.setup({
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
						option = {
							---Return the directory that `cmp-path` will use when inserting relative paths
							---@param cmp_data table<string, any> Data provided by `cmp-path`
							---@return string current_working_directory
							get_cwd = function(cmp_data)
								local buffer_nr = cmp_data.context.bufnr
								local path_expand_expr = ':p:h'

								-- Use the git repository root directory when editing the '.git/COMMIT_EDITMSG' file
								if vim.bo[buffer_nr].filetype == 'gitcommit' then
									path_expand_expr = ':p:h:h'
								end

								return vim.fn.expand('#' .. buffer_nr .. path_expand_expr)
							end
						}
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
								if buffer_size > 10 * 1024 * 1024 then return false end

								return true
							end

							-- Gets all buffers and filter them before send to CMP
							local buffers = vim.api.nvim_list_bufs()
							return vim.tbl_filter(filter_buffers, buffers)
						end
					},
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'lazydev' },  -- Suggestions to `require()`
				},

				sorting = {
					priority_weight = 1,

					comparators = {
						-- Words next to the cursor line have higher priority
						function(...)
							return cmp_buffer:compare_locality(...)
						end
					}
				},

				mapping = {
					-- Auto complete
					['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select, count = 6 }),
					['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select , count = 6 }),
					['<Left>'] = close_completion,
					['<Right>'] = close_completion,
					['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace }),

					['<A-CR>'] = function(fallback)
						if luasnip.expandable() then
							luasnip.expand()
						else
							fallback()
						end
					end,

					['<Tab>'] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						elseif luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end,
					['<S-Tab>'] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select})
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end,

					-- Docs
					['<C-d>'] = cmp.mapping.scroll_docs(4),
					['<C-u>'] = cmp.mapping.scroll_docs(-4),
				},

				 snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end
				},

				-- Custom formatting to the suggestions
				formatting = {
					expandable_indicator = true,

					fields = { 'kind', 'abbr', 'menu' },

					format = function(entry, vim_completed_item)
						local kind = lspkind.presets.default[vim_completed_item.kind]        -- Convert the kind with lspkind
						vim_completed_item.kind = ' ' .. (kind or '?') .. ' '
						vim_completed_item.menu =  source_name2item_menu[entry.source.name]  -- Add the source name to the menu

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
				}
			})

			-- Completions for command mode
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = 'path' },
					{ name = 'cmdline' },
				})
			})
		end
	},
}
