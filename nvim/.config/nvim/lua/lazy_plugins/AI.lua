--- Models

local gemini_model = 'gemma-4-31b-it'
local gemini_fast_model = 'gemini-3.1-flash-lite'

-- You can set it with the command `secret-tool store --label="Google AI Studio API Key" google-ai-studio api-key`
local gemini_api_auth = 'cmd:secret-tool lookup google-ai-studio api-key'

local cached_gemini_key = nil

---Get the API key from the system secret store.
---@return string?
local function get_gemini_key()
	if cached_gemini_key then
		return cached_gemini_key
	end

	local result = vim.system({ 'secret-tool', 'lookup', 'google-ai-studio', 'api-key' }, { text = true }):wait()

	if result.code == 0 and result.stdout then
		cached_gemini_key = vim.trim(result.stdout)
	end

	return cached_gemini_key
end

local normal_visual_mode = { 'n', 'v' }

return {
	{
		'milanglacier/minuet-ai.nvim',

		cmd = 'Minuet',

		opts = {
			provider = 'gemini',

			virtualtext = {
				auto_trigger_ft = { '*' },
				keymap = {
					accept = '<A-Tab>',
					prev = '<A-[>',
					next = '<A-]>',
					dismiss = '<A-e>',
				},
			},

			n_completions = 1,
			provider_options = {
				gemini = {
					api_key = get_gemini_key,
					model = gemini_fast_model,
					stream = true,
				},
			},
		},
		config = function(_, opts)
			require('minuet').setup(opts)
		end,
	},
	{
		'ravitemer/mcphub.nvim',

		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		build = 'pnpm install -g mcp-hub@latest',

		cond = MYVAR.not_in_vscode,

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

		cond = MYVAR.not_in_vscode,

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
									api_key = gemini_api_auth,
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
			'nvim-telescope/telescope.nvim',
			'nvim-tree/nvim-web-devicons',
		},

		build = 'make',

		cond = MYVAR.not_in_vscode,

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
					api_key_name = gemini_api_auth,
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
