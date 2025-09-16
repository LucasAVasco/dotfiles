--- Models

local gemini_model = 'gemini-2.0-flash'
local gemini_api_key = 'cmd:secret-tool lookup GEMINI_API KEY'

local normal_visual_mode = { 'n', 'v' }

return {
	{
		'Exafunction/windsurf.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},

		event = 'InsertEnter',
		cmd = 'Codeium',

		opts = {
			enable_cmp_source = false, -- I use the virtual text to show the suggestions

			virtual_text = {
				enabled = true,
				key_bindings = {
					accept = '<A-Tab>',
					next = '<A-]>',
					prev = '<A-[>',
				},
			},
		},

		config = function(_, opts)
			require('codeium').setup(opts)
			vim.api.nvim_set_hl(0, 'CodeiumSuggestion', { link = 'Comment' })
		end,
	},
	{
		'ravitemer/mcphub.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		build = 'npm install -g mcp-hub@latest',

		cmd = 'MCPHub',

		opts = {
			extensions = {
				-- From the official documentation at https://ravitemer.github.io/mcphub.nvim/extensions/avante.html
				avante = {
					make_slash_commands = true,
				},
			},
		},
	},
	{
		'olimorris/codecompanion.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',

			-- MCPHub
			'ravitemer/mcphub.nvim',
		},

		cmd = {
			'CodeCompanion',
			'CodeCompanionChat',
			'CodeCompanionActions',
			'CodeCompanionCmd',
		},

		keys = {
			{ '<leader>AA', '<CMD>CodeCompanionActions<CR>', mode = normal_visual_mode, desc = 'Actions' },
			{ '<leader>AC', '<CMD>CodeCompanionChat<CR>', mode = normal_visual_mode, desc = 'Chat' },

			{ '<leader>Ac', '<CMD>CodeCompanion /commit<CR>', mode = normal_visual_mode, desc = 'create commit' },
			{ '<leader>Ad', '<CMD>CodeCompanion /lsp<CR>', mode = normal_visual_mode, desc = 'treat LSP diagnostics' },
			{ '<leader>Ae', '<CMD>CodeCompanion /explain<CR>', mode = normal_visual_mode, desc = 'explain code' },
			{ '<leader>Af', '<CMD>CodeCompanion /fix<CR>', mode = normal_visual_mode, desc = 'fix errors' },
			{ '<leader>Ai', '<CMD>CodeCompanion /buffer<CR>', mode = normal_visual_mode, desc = 'inline buffer' },
			{ '<leader>At', '<CMD>CodeCompanion /tests<CR>', mode = normal_visual_mode, desc = 'test code' },
			{ '<leader>Aw', '<CMD>CodeCompanion /workflow<CR>', mode = normal_visual_mode, desc = 'workflow' },
		},

		config = function()
			local code_comp = require('codecompanion')
			code_comp.setup({
				adapters = {
					http = {
						gemini = function()
							return require('codecompanion.adapters').extend('gemini', {
								name = 'gemini',
								schema = {
									model = {
										default = gemini_model,
									},
								},
								env = {
									api_key = gemini_api_key,
								},
							})
						end,
					},
				},

				strategies = {
					chat = {
						adapter = 'gemini',
					},

					inline = {
						adapter = 'gemini',
					},
				},

				extensions = {
					-- From the official documentation at https://ravitemer.github.io/mcphub.nvim/extensions/codecompanion.html
					mcphub = {
						callback = 'mcphub.extensions.codecompanion',
						opts = {
							add_mcp_prefix_to_tool_names = true,
							format_tool = nil,
							make_slash_commands = true,
							make_tools = true,
							make_vars = true,
							show_result_in_chat = true,
							show_server_tools_in_chat = true,
						},
					},
				},

				-- Appearance {{{

				display = {
					chat = {
						show_settings = true, -- Model information at the top of the chat

						window = {
							position = 'left',
						},
					},
				},

				-- }}}
			})
		end,
	},
	{
		'yetone/avante.nvim',
		dependencies = {
			'MunifTanjim/nui.nvim',
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',

			-- MCPHub
			'ravitemer/mcphub.nvim',

			--- Optional dependencies
			'hrsh7th/nvim-cmp',
			'nvim-telescope/telescope.nvim',
			'nvim-tree/nvim-web-devicons',
		},

		build = 'make',

		keys = {
			{ '<leader>a' },
		},

		---@module "avante.config"
		---@type avante.Config
		opts = {
			provider = 'gemini',
			providers = {
				gemini = {
					model = gemini_model,
					api_key_name = gemini_api_key,
				},
			},

			-- From the official documentation at https://ravitemer.github.io/mcphub.nvim/extensions/avante.html
			system_prompt = function()
				local hub = require('mcphub').get_hub_instance()
				return hub and hub:get_active_servers_prompt() or ''
			end,

			custom_tools = function()
				return {
					require('mcphub.extensions.avante').mcp_tool(),
				}
			end,

			-- Appearance {{{

			windows = {
				width = 45,
				position = 'left',
			},

			-- }}}
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>a', 'Avante')
		end,
	},
}
