---@type table<string, string[]|"*"> Relates the LSP server name with its filetypes
MYPLUGVAR.lsp_filetypes = {}

---List of LSP servers already configured
---@type table<string, boolean>
local configured_lspconfig_servers = {}

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

			local filetypes_config = require('my_configs.LSP.filetypes')

			local client_capabilities = require('blink.cmp').get_lsp_capabilities({})

			vim.lsp.config('*', {
				capabilities = client_capabilities,
			})

			---Return if the LSP server configuration should be aborted (E.g. The user disabled the server)
			---@param server_name string Name of the LSP server to check
			---@return boolean should_abort_configuration
			---@nodiscard
			local function should_abort_lsp_config(server_name)
				return vim.tbl_contains(MYVAR.lsp_servers_to_disable, server_name)
			end

			---Configure a LSP server. Do not enable it.
			---@param name string Name of the LSP server
			local function configure_lsp_server(name)
				-- Only configures once
				if configured_lspconfig_servers[name] then
					return
				end
				configured_lspconfig_servers[name] = true

				-- Applies my LSP server configuration

				---@type boolean, my_configs.LSP.LspServerConfig
				local ok, server_opts = pcall(require, 'my_configs.LSP.configs.' .. name)

				if not ok then
					server_opts = {}
				end

				-- Overrides file-types
				local filetypes = MYPLUGVAR.lsp_filetypes[name]
				if type(filetypes) == 'table' then
					server_opts.filetypes = filetypes
				end

				vim.lsp.config(name, server_opts)
			end

			---Enable a LSP server (automatically starts it when a match file type is found)
			---@param name string Name of the LSP server
			local function enable_lsp_server(name)
				configure_lsp_server(name)
				vim.lsp.enable(name)
			end

			---Start a LSP server
			---@param name string Name of the LSP server
			---@param config vim.lsp.Config? Optional configuration. Automatically retrieved if nil
			local function start_lsp_server(name, config)
				enable_lsp_server(name)

				config = config or vim.lsp.config[name]
				if config == nil then
					error('LSP server "' .. name .. '" not found')
				end

				local filetype = config.filetypes[1]
				if filetype == nil then
					error('LSP server "' .. name .. '" has no associated filetypes')
				end

				-- Start the LSP server by opening a new buffer with the associated file type
				local buf_id = vim.api.nvim_create_buf(false, false)
				vim.bo[buf_id].filetype = config.filetypes[1]
				vim.schedule(function()
					vim.api.nvim_buf_delete(buf_id, {})
				end)
			end

			---Lazy load the LSP server configuration (only sets up the LSP server when a match file type is found)
			---@param lsp_server_name string Name of the server. Same values used in `require('lspconfig')[lsp_server_name]`.
			local function lazy_load_lsp_server(lsp_server_name)
				if should_abort_lsp_config(lsp_server_name) then
					return
				end

				local config = vim.lsp.config[lsp_server_name]
				if config == nil then
					return
				end

				---Attach the LSP server to these file types
				---@type string[]|'*'
				local filetypes = config.filetypes or '*'

				local override_filetypes = filetypes_config.override[lsp_server_name]
				if override_filetypes then
					filetypes = override_filetypes
				end

				local append_filetypes = filetypes_config.extend[lsp_server_name]
				if append_filetypes then
					if type(filetypes) == 'table' and type(append_filetypes) == 'table' then
						MYFUNC.array_concat(filetypes, append_filetypes)
					else
						filetypes = '*'
					end
				end

				-- Maps the LSP server to the file types
				MYPLUGVAR.lsp_filetypes[lsp_server_name] = filetypes

				-- Automatically starts the LSP server for the file types
				vim.api.nvim_create_autocmd('FileType', {
					pattern = filetypes,
					callback = function()
						enable_lsp_server(lsp_server_name)
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
			vim.api.nvim_create_user_command('LspStart', function(args)
				for _, lsp_server_name in ipairs(args.fargs) do
					start_lsp_server(lsp_server_name, nil)
				end
			end, {
				nargs = '+',
			})

			vim.api.nvim_create_user_command('LspAttach', function(args)
				local server_name = args.fargs[1]
				local id = args.fargs[2] and tonumber(args.fargs[2]) or 0

				start_lsp_server(server_name)

				-- Wait for the LSP server to be attached to the buffer
				vim.wait(1000, function()
					for _, client in pairs(vim.lsp.get_clients()) do
						if client.name == server_name then
							vim.lsp.buf_attach_client(id, client.id)
							return true
						end
					end

					return false
				end, 100)
			end, {
				nargs = '+',
			})

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
