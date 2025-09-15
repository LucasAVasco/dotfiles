---@type table<string, string[]|"*"> Relates the LSP server name with its filetypes
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

			local client_capabilities = require('cmp_nvim_lsp').default_capabilities()

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
				local filetypes = MYPLUGVAR.lspFileTypes[lsp_server_name]
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

					vim.cmd.LspStart({ args = { server_name } })
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

				MYPLUGVAR.lspFileTypes[lsp_server_name] = filetypes

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
