return {
	{
		'rachartier/tiny-inline-diagnostic.nvim',
		event = 'DiagnosticChanged',

		opts = {
			preset = 'modern',

			options = {
				-- Shows diagnostic source.
				show_source = {
					enabled = true,
					if_many = false, -- Only shows the source if there are many sources
				},

				throttle = 100, -- Update time of diagnostic pop-up in milliseconds

				-- Multi-line diagnostics (shows a diagnostics pop-up even if the cursor is not on the line) {{{

				add_messages = false, -- Shows messages on multi-line diagnostics

				multilines = {
					enabled = true,
					always_show = true,
				},

				virt_texts = {
					priority = 5000, -- Bigger than the priority used by the search utility of the 'noice.nvim' plugin
				},

				-- }}}

				--- Wrapping long messages {{{

				-- If the message length is lower that this number of bytes, puts it below the cursor. Otherwise, puts at the end of line
				softwrap = 0,

				overflow = {
					mode = 'wrap',
					padding = 5, -- Padding at the right of the diagnostic. Requires `mode = "wrap"`
				},

				--- }}}
			},

			disabled_ft = MYVAR.utilities_ft,
		},

		init = function()
			vim.diagnostic.config({
				virtual_text = false,
				signs = {
					text = {
						[vim.diagnostic.severity.HINT] = '',
						[vim.diagnostic.severity.INFO] = '',
						[vim.diagnostic.severity.WARN] = '',
						[vim.diagnostic.severity.ERROR] = '',
					},
				},
			})
		end,

		config = function(_, opts)
			local tiny_inline_diagnostic = require('tiny-inline-diagnostic')
			tiny_inline_diagnostic.setup(opts)

			-- This plugin does not attach to buffers if the LSP server is already attached to it. You need to manually attach
			-- 'tiny-inline-diagnostic' to all buffers with LSP servers already attached

			local lsp_clients = vim.lsp.get_clients()

			for _, client in pairs(lsp_clients) do
				local data = {
					client_id = client.id,
				}

				for buffer_number in pairs(client.attached_buffers) do
					vim.api.nvim_exec_autocmds('LspAttach', {
						buffer = buffer_number,
						data = data,
					})
				end
			end
		end,
	},
}
