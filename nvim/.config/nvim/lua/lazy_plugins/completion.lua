--[[ autodoc
	====================================================================================================
	Auto-completion keymaps (Plugin)[map]                                         *plugin-completion-keymaps*

	Use `<M-e>` to use Fast Wrap. It will show virtual texts indicating the position to place the closing
	pair. Press this key to insert. If you select the Shift key, it will insert the closing pair and go to it

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
		version = 'v2.3.0',
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
			require('luasnip.loaders.from_lua').load({ paths = {'~/.config/nvim/lua_snippets'} })
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

		config = function(plugin, opts)
			local npairs = require('nvim-autopairs')
			local Rule = require('nvim-autopairs.rule')

			npairs.setup(opts)

			npairs.add_rules({
				Rule('"""', '"""')  -- Triple quotes string (like the Python docstrings)
			})

			-- Auto-pairs integration with cmp-nvim
			require('cmp').event:on(
				'confirm_done',
				require('nvim-autopairs.completion.cmp').on_confirm_done()
			)
		end,
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
			}

			--- Configures the highlighting groups that will be used in the suggestions menu
			local function update_cmp_hl()
				-- Get all highlight groups and apply the customization to the ones that will appear in the item kind.
				-- They start with `CmpItemKind`
				local all_hl_groups = vim.api.nvim_get_hl(0, {})

				for hl_group_name, hl_group_contents in pairs(all_hl_groups) do
					if string.find(hl_group_name, '^CmpItemKind') then
						local new_hl = myfunc.get_hl_definition(hl_group_name)
						new_hl.standout = true  -- Makes the text stand out (swap background and foreground colors)
						new_hl.bold = true
						vim.api.nvim_set_hl(0, hl_group_name, new_hl)
					end
				end
			end

			-- Applies the custom highlighting to all color schemes
			vim.api.nvim_create_autocmd('ColorScheme', {
				pattern = '*', callback = update_cmp_hl
			})

			update_cmp_hl()

			--- Closes the completion and runs the fallback
			-- It is diferent from `cmp.close` that runs the fallback only if the completion is closed. This
			-- function do the both at the same time.
			-- @param fallback Fallback function
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
					enabled = enabled and vim.api.nvim_buf_get_option(0, 'buftype') ~= 'prompt'

					return enabled

				end,

				sources = {
					{ name = 'path' },
					{
						name = 'buffer',
						get_bufnrs = function()
							--- Filter to get the buffers that will be used in this suggestions
							-- @param buf_nr Buffer number
							-- @return if the buffer should be used in the suggestions (true or false)
							local function filter_buffers(buf_nr)
								-- Only uses normal buffers
								if vim.api.nvim_buf_get_option(buf_nr, 'buftype') ~= '' then
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
				},

				sorting = {
					comparators = {
						-- Words next to the cursor line have higher priority
						function(...)
							return cmp_buffer:compare_locality(...)
						end
					}
				},

				mapping = {
					-- Auto complete
					['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert, count = 6 }),
					['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert, count = 6 }),
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
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
						elseif luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end,
					['<S-Tab>'] = function()
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
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
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_completed_item)
						local kind = lspkind.presets.default[vim_completed_item.kind]        -- Convert the kind with lspkind
						vim_completed_item.kind = ' ' .. kind .. ' '
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
