---@type table<string, string[]|"*"> Relates the LSP server name with its filetypes
MYPLUGVAR.lsp_filetypes = {}

return {
	{
		'neovim/nvim-lspconfig',

		cond = MYVAR.not_in_vscode,

		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',
			'saghen/blink.cmp',
			'b0o/schemastore.nvim', -- Used by 'jsonls' and 'yamlls'

			-- Required by my commands
			'MunifTanjim/nui.nvim', -- 'LspFileTypes' command
		},

		event = 'User MyEventOpenEditableFile',

		cmd = {
			-- Commands deprecated by 'nvim-lspconfig', but that are re-implemented here
			'LspInfo',
			'LspLog',

			-- My commands
			'LspFileTypes',
		},

		config = function()
			-- Enable codelens
			vim.lsp.codelens.enable(true)

			-- Mason configuration to automatically download LSP servers. The setup order is required: 1. mason, 2. mason-lspconfig,
			-- 3. nvim-lspconfig
			require('mason') -- Configured in another file
			local mason_lspconfig = require('mason-lspconfig')

			mason_lspconfig.setup({
				automatic_enable = false,

				automatic_installation = true,
			})

			---Return if the LSP server configuration should be aborted (E.g. The user disabled the server)
			---@param server_name string Name of the LSP server to check
			---@return boolean should_abort_configuration
			---@nodiscard
			local function should_abort_lsp_config(server_name)
				return vim.tbl_contains(MYVAR.lsp_servers_to_disable, server_name)
			end

			local client_capabilities = require('blink.cmp').get_lsp_capabilities({})

			vim.lsp.config('*', {
				capabilities = client_capabilities,
			})

			---List of LSP servers already configured
			---@type table<string, boolean>
			local configured_lspconfig_servers = {}

			local function setup_lsp_server(lsp_server_name)
				-- Only configures once
				if configured_lspconfig_servers[lsp_server_name] then
					return
				else
					configured_lspconfig_servers[lsp_server_name] = true
				end

				-- Applies my LSP server configuration

				---@type boolean, my_configs.LSP.LspServerConfig
				local ok, server_opts = pcall(require, 'my_configs.LSP.configs.' .. lsp_server_name)

				if not ok then
					server_opts = {}
				end

				-- Overrides file-types
				local filetypes = MYPLUGVAR.lsp_filetypes[lsp_server_name]
				if type(filetypes) == 'table' then
					server_opts.filetypes = filetypes
				end

				vim.lsp.config(lsp_server_name, server_opts)
				vim.lsp.enable(lsp_server_name)
			end

			local lsp_filetypes_overrides = require('my_configs.LSP.filetypes')

			local function start_lsp_server(server_name)
				vim.schedule(function()
					-- Does not start the LSP server if it is already started
					for _, client in pairs(vim.lsp.get_clients()) do
						if client.name == server_name then
							return
						end
					end

					if MYVAR.not_in_vscode then
						vim.cmd.lsp({ args = { 'enable', server_name } })
					end
				end)
			end

			---Setup a LSP server by its name
			---@param lsp_server_name string Name of the server. Same values used in `require('lspconfig')[lsp_server_name]`.
			local function lazy_load_lsp_server(lsp_server_name)
				if should_abort_lsp_config(lsp_server_name) then
					return
				end

				---Attach the LSP server to these file types
				---@type string|string[]
				local filetypes = vim.lsp.config[lsp_server_name].filetypes or '*'

				if lsp_filetypes_overrides[lsp_server_name] then
					filetypes = lsp_filetypes_overrides[lsp_server_name]
				end

				-- Maps the LSP server to the file types
				MYPLUGVAR.lsp_filetypes[lsp_server_name] = filetypes

				-- Automatically starts the LSP server for the file types
				vim.api.nvim_create_autocmd('FileType', {
					pattern = filetypes,
					callback = function()
						setup_lsp_server(lsp_server_name)
						start_lsp_server(lsp_server_name)

						return true -- Must setup the server only once
					end,
				})
			end

			local installed_mason_lsp_servers = mason_lspconfig.get_installed_servers()
			for _, lsp_server_name in ipairs(installed_mason_lsp_servers) do
				lazy_load_lsp_server(lsp_server_name)
			end

			for _, lsp_server_name in ipairs(require('my_configs.LSP.auto-config')) do
				lazy_load_lsp_server(lsp_server_name)
			end

			-- Re-implements some 'nvim-lspconfig' commands
			vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', {})
			vim.api.nvim_create_user_command('LspLog', 'edit ~/.local/state/nvim/lsp.log', {})

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
				local lines = MYFUNC.str_split(vim.inspect(MYPLUGVAR.lsp_filetypes), '\n')
				vim.api.nvim_buf_set_lines(popup.bufnr, 2, -1, true, lines)

				popup:mount()
			end, {
				desc = 'Shows the configured LSP servers',
			})
		end,
	},
	{
		'ray-x/lsp_signature.nvim',

		cond = MYVAR.not_in_vscode,
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

		cond = MYVAR.not_in_vscode,
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

		cond = MYVAR.not_in_vscode,
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
