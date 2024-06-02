return {
	{
		'ray-x/lsp_signature.nvim',

		opts = {
			hint_prefix = "󰙎: ",
			handler_opts = { border = 'rounded' },
			max_width = 80,
		},

		config = function(plugin, opts)
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
		'hrsh7th/cmp-nvim-lsp',

		dependencies = {
			'neovim/nvim-lspconfig',
			'ray-x/lsp_signature.nvim',
		},

		config = function()
			-- Servers configuration can be found in the official documentation:
			-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
			local nvim_lspconfig = require('lspconfig')

			-- Overrides default configuration
			nvim_lspconfig.util.default_config = vim.tbl_deep_extend(
				'force', nvim_lspconfig.util.default_config,
				{
					handlers = {
						-- Adds rounded borders to hover popup
						['textDocument/hover'] =  vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded'}),
					}
				}
			)

			-- Override the default capabilities to be used in the configuration of LSP servers
			-- Use the `myplugfunc.get_lsp_capabilities` function to get the LSP capabilities in other plugins
			-- Remember to call this function after `cmp-nvim-lsp` is loaded. So add `cmp-nvim-lsp` in `dependencies`
			-- of these plugins
			local client_capabilities = require('cmp_nvim_lsp').default_capabilities()

			--- Get the capabilities of the current LSP client
			-- This function need to be called after 'cmp-nvim-lsp' be loaded
			-- @return The LSP capabilities
			function myplugfunc.lsp_get_capabilities()
				return client_capabilities
			end

			--- Restart a LSP server
			-- Need to provide a index of the LSP server, a table of indexes or 'all'. If not provided, restarts the first LSP server
			-- @param server_index Indexes of the LSP servers to restart
			function myplugfunc.lsp_restart_server(server_index)
				local servers = vim.lsp.get_active_clients()

				-- Get te list of LSP servers to restart (its index)
				local to_restart = nil
				if server_index == 'all' then
					to_restart = servers

				elseif type(server_index) == 'number' then
					to_restart = { servers[server_index] }

				elseif type(server_index) == 'table' then
					to_restart = server_index

				elseif server_index == nil then  -- First LSP server
						to_restart = { servers[1] }
				end

				-- Restart all selected LSP servers
				for _, server in ipairs(to_restart) do
					vim.cmd('LspRestart ' .. server.id)
				end
			end

			-- User command to configure the current LSP server and its dependencies (based on the server name)
			myfunc.add_setup_command('lsp configure auto', function()
				local server = vim.lsp.get_active_clients()[1]

				if not server then  -- If there is no LSP server
					vim.notify('No LSP server found', vim.log.levels.ERROR)
					return
				end

				vim.cmd('Setup lsp configure ' .. server.name)

			end)
		end
	},
}
