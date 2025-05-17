---@type table<string, string[]|string> Relates the LSP server name with its filetypes
MYPLUGVAR.lspFileTypes = {}

return {
	{
		'neovim/nvim-lspconfig',

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'hrsh7th/cmp-nvim-lsp',
			'folke/neoconf.nvim',
			'b0o/schemastore.nvim', -- Used by 'jsonls' and 'yamlls'

			-- Required by my commands
			'MunifTanjim/nui.nvim', -- 'LspFileTypes' command
		},

		event = 'User MyEventOpenEditableFile',

		cmd = {
			'LspInfo',
			'LspLog',
			'LspRestart',
			'LspStart',
			'LspStop',

			-- My commands
			'LspFileTypes',
		},

		config = function()
			-- Uses `neoconf` to get a list of LSP servers to enable or disable
			local selected_lsp = {
				disable = {},
				enable = {},
			}

			require('neoconf.plugins').register({
				name = 'Lsp-select',
				on_schema = function(schema)
					schema:import('selected-lsp', selected_lsp)

					schema:set('selected-lsp.enable', {
						description = 'LSP servers to enable (disable all others)',
						anyOf = { { type = 'string' } },
					})

					schema:set('selected-lsp.disable', {
						description = 'LSP servers to disable (enable all others)',
						anyOf = { { type = 'string' } },
					})
				end,
			})

			-- Query the selected LSP servers from `neoconf`. The user can not provide the 'enabled' and 'disable' fields at the same time.
			-- So this variable will have at least one empty list
			selected_lsp = require('neoconf').get('selected-lsp', selected_lsp)

			-- Mason configuration to automatically download LSP servers. The setup order is required: 1. mason, 2. mason-lspconfig,
			-- 3. nvim-lspconfig
			require('mason') -- Configured in another file
			local mason_lspconfig = require('mason-lspconfig')

			mason_lspconfig.setup({
				automatic_enable = false,

				automatic_installation = true,

				ensure_installed = {
					'lua_ls', -- Used to check Neovim configuration
					'jsonls', -- Used by `neoconf.nvim`
					'yamlls',
				},
			})

			---Return if the LSP server configuration should be aborted (E.g. The user disabled the server)
			---@param server_name string Name of the LSP server to check
			---@return boolean should_abort_configuration
			---@nodiscard
			local function should_abort_lsp_config(server_name)
				-- Lists of LSP servers to disable
				if vim.tbl_contains(selected_lsp.disable, server_name) or vim.tbl_contains(MYVAR.lsp_servers_to_disable, server_name) then
					return true
				end

				-- If the user enabled some LSP server, need to disable all the other servers
				if #selected_lsp.enable > 0 and not vim.tbl_contains(selected_lsp.enable, server_name) then
					return true
				end

				-- Fallback value
				return false
			end

			local lspconfig = require('lspconfig')
			local client_capabilities = require('cmp_nvim_lsp').default_capabilities()

			---Default settings applied to all LSP servers
			---@type MyLspServerConfig
			---@diagnostic disable-next-line: missing-fields
			local default_lspconfiguration = {
				capabilities = client_capabilities,
			}

			local lsp_filetypes_overrides = require('my_configs.LSP.filetypes')

			local installed_mason_lsp_servers = mason_lspconfig.get_installed_servers()
			for _, lsp_server_name in pairs(installed_mason_lsp_servers) do
				if should_abort_lsp_config(lsp_server_name) then
					return
				end

				---Attach the LSP server to these file types
				---@type string|string[]
				local filetypes = lspconfig[lsp_server_name].config_def.default_config.filetypes or '*'

				if lsp_filetypes_overrides[lsp_server_name] then
					filetypes = lsp_filetypes_overrides[lsp_server_name]
				end

				MYPLUGVAR.lspFileTypes[lsp_server_name] = filetypes

				vim.api.nvim_create_autocmd('FileType', {
					pattern = filetypes,
					callback = function()
						---@type boolean, MyLspServerConfig
						local ok, server_opts = pcall(require, 'my_configs.LSP.configs.' .. lsp_server_name)

						if ok then
							server_opts.capabilities = client_capabilities
						else
							server_opts = default_lspconfiguration
						end

						lspconfig[lsp_server_name].setup(server_opts)
						vim.cmd.LspStart({ args = { lsp_server_name } })

						return true -- Must setup the server only one time
					end,
				})
			end

			-- TODO(LucasAVasco): Find a decent way to run 'yarn dlx @yarnpkg/sdks base' in a Yarn repository to configure `tsserver`

			-- Manually starts the LSP servers. `nvim-lspconfig` needs to be configured before Neovim attempts to start an LSP server in a
			-- buffer. Otherwise, `nvim-lspconfig` may not configure it. The following line ensures that the LSP servers will be started
			-- even if `nvim-lspconfig` is configured after Neovim's attempt
			vim.cmd('LspStart')

			-- Command to show configured LSP servers and its supported  file types
			vim.api.nvim_create_user_command('LspFileTypes', function()
				local NuiPopup = require('nui.popup')
				local popup = NuiPopup({
					focusable = true,
					enter = true,
					border = 'rounded',
					position = '50%',
					buf_options = {
						filetype = 'lua',
					},
					size = {
						width = '80%',
						height = '80%',
					},
				})

				popup:on('BufLeave', function()
					popup:unmount()
				end)

				popup:map('n', 'q', function()
					popup:unmount()
				end)

				-- Header (first line)
				vim.api.nvim_buf_set_lines(popup.bufnr, 0, 0, true, { '-- LSP servers and its file types' })

				-- body (LSP servers and its file types)
				local lines = MYFUNC.str_split(vim.inspect(MYPLUGVAR.lspFileTypes), '\n')
				vim.api.nvim_buf_set_lines(popup.bufnr, 2, -1, true, lines)

				popup:mount()
			end, {
				desc = 'Shows the configured LSP servers',
			})
		end,
	},
	{
		'ray-x/lsp_signature.nvim',
		event = 'InsertEnter',
		opts = {
			floating_window = false, -- Only use virtual text

			hint_scheme = '@variable.parameter',
			hint_inline = function()
				return 'eol'
			end,
		},
	},
	{
		'kosayoda/nvim-lightbulb',
		event = 'LspAttach',

		opts = {
			priority = 100,

			autocmd = {
				enabled = true,
				events = {
					-- Default events tracked by the plugin
					'CursorHold',
					'CursorHoldI',

					-- Events that I want to track
					'CursorMoved',
					'CursorMovedI',
				},
			},

			code_lenses = true,
		},
	},
	{
		'nvimdev/lspsaga.nvim',

		dependencies = {
			'neovim/nvim-lspconfig',
			'nvim-tree/nvim-web-devicons',
		},

		cmd = 'Lspsaga',

		opts = {
			symbol_in_winbar = {
				enable = false, -- I use 'dropbar.nvim' instead
			},
			lightbulb = {
				enable = false, -- I use 'nvim-lightbulb' instead
			},

			ui = {
				border = 'rounded',
			},
		},
	},
}
