return {
	{
		'neovim/nvim-lspconfig',

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'hrsh7th/cmp-nvim-lsp',
			'folke/neoconf.nvim',
			'b0o/schemastore.nvim', -- Used by 'jsonls' and 'yamlls'
		},

		event = 'User MyEventOpenEditableFile',

		cmd = {
			'LspInfo',
			'LspLog',
			'LspRestart',
			'LspStart',
			'LspStop',
		},

		config = function()
			-- Uses `neoconf` to get a list of LSP servers to enable or disable
			local selected_lsp = {
				disable = {},
				enable = {},
			}

			require('neoconf.plugins').register({
				name='Lsp-select',
				on_schema = function(schema)
					schema:import('selected-lsp', selected_lsp)

					schema:set('selected-lsp.enable', {
						description = "LSP servers to enable (disable all others)",
						anyOf = { {type = 'string'} },
					})

					schema:set('selected-lsp.disable', {
						description = "LSP servers to disable (enable all others)",
						anyOf = { {type = 'string'} },
					})
				end
			})

			-- Query the selected LSP servers from `neoconf`. The user can not provide the 'enabled' and 'disable' fields at the same time.
			-- So this variable will have at least one empty list
			selected_lsp = require('neoconf').get('selected-lsp', selected_lsp)

			-- Mason configuration to automatically download LSP servers. The setup order is required: 1. mason, 2. mason-lspconfig,
			-- 3. nvim-lspconfig
			require('mason')  -- Configured in another file
			local mason_lspconfig = require('mason-lspconfig')

			mason_lspconfig.setup({
				automatic_installation = true,

				ensure_installed = {
					'lua_ls',     -- Used to check Neovim configuration
					'typos_lsp',  -- Spell checker
					'jsonls',     -- Used by `neoconf.nvim`
					'yamlls',
				},
			})

			---Return if the LSP server configuration should be aborted (E.g. The user disabled the server)
			---@param server_name string Name of the LSP server to check
			---@return boolean should_abort_configuration
			---@nodiscard
			local function should_abort_lsp_config(server_name)
				-- Lists of LSP servers to disable
				if vim.tbl_contains(selected_lsp.disable, server_name) or
					vim.tbl_contains(MYVAR.lsp_servers_to_disable, server_name) then
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
			local default_lspconfiguration = {
				capabilities = client_capabilities
			}

			mason_lspconfig.setup_handlers({
				---Fallback handler used when not provided a specific server configuration. Need to be the first element in this table
				---@param lsp_server_name string
				function (lsp_server_name)
					if should_abort_lsp_config(lsp_server_name) then
						return
					end

					-- Gets the LSP server options from my configuration directory

					---@type boolean, any
					local ok, server_opts = pcall(require, "my_configs.LSP.configs." .. lsp_server_name)

					if ok then
						server_opts.capabilities = client_capabilities
					else
						server_opts=default_lspconfiguration
					end

					lspconfig[lsp_server_name].setup(server_opts)
				end,
			})

			-- TODO(LucasAVasco): Find a decent way to run 'yarn dlx @yarnpkg/sdks base' in a Yarn repository to configure `tsserver`

			-- Overrides the default configuration
			lspconfig.util.default_config = vim.tbl_deep_extend(
				'force', lspconfig.util.default_config,
				{
					handlers = {
						-- Adds rounded borders to hover pop up
						['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
					}
				}
			)

			-- Manually starts the LSP servers. `nvim-lspconfig` needs to be configured before Neovim attempts to start an LSP server in a
			-- buffer. Otherwise, `nvim-lspconfig` may not configure it. The following line ensures that the LSP servers will be started
			-- even if `nvim-lspconfig` is configured after Neovim's attempt
			vim.cmd('LspStart')
		end
	},
	{
		'nvimdev/lspsaga.nvim',

		dependencies = {
			'neovim/nvim-lspconfig',
			'nvim-tree/nvim-web-devicons',
		},

		event = 'LspAttach',

		cmd = 'Lspsaga',

		opts = {
			lightbulb = {
				virtual_text = false,  -- Only shows the light bulb in the sign column
			},

			ui = {
				border = 'rounded',
				code_action = '󰌵',  -- The default light bulb icon did not work with my font
			},
		}
	}
}
