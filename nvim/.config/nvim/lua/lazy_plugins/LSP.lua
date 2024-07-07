return {
	{
		'ray-x/lsp_signature.nvim',

		opts = {
			hint_prefix = "󰙎: ",
			handler_opts = { border = 'rounded' },
			max_width = 80,
		},

		config = function(_, opts)
			local lsp_signature = require('lsp_signature')

			-- Attach 'lsp_signature' to all buffers with a LSP server
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(arguments)
					lsp_signature.on_attach(opts, arguments.buf)
				end,
			})
		end
	},
	{
		'neovim/nvim-lspconfig',

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'hrsh7th/cmp-nvim-lsp',
			'folke/neoconf.nvim',
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
			require('mason').setup()
			local mason_lspconfig = require('mason-lspconfig')

			mason_lspconfig.setup({
				automatic_installation = true,

				ensure_installed = {
					'lua_ls',     -- Used to check Neovim configuration
					'typos_lsp',  -- Spell checker
					'jsonls',     -- Used by `neoconf.nvim`
				},
			})

			local client_capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require('lspconfig')
			mason_lspconfig.setup_handlers({
				-- Fallback handler used when not provided a specif server configuration. Need to be first element in this table
				function (lsp_server_name)
					if vim.tbl_contains(selected_lsp.disable, lsp_server_name) then
						return
					end

					-- If the user enabled some LSP server, need to disable all the other servers
					if #selected_lsp.enable > 0 and not vim.tbl_contains(selected_lsp.enable, lsp_server_name) then
						return
					end

					-- Fallback option
					lspconfig[lsp_server_name].setup({
						capabilities=client_capabilities
					})
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
		end
	}
}
