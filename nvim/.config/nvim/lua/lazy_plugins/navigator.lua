return {
	{
		'ray-x/navigator.lua',
		dependencies = {
			'ray-x/guihua.lua',
			'neovim/nvim-lspconfig',
		},

		priority = 10000,

		opts = {
			-- debug = true,

			border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },

			mason = false,

			lsp = {
				disable_lsp = 'all', -- I configure my LSP servers manually with 'nvim-lspconfig' and Mason

				hover = false, -- Disables the 'K' key-map (overridden by 'noice.nvim')

				-- Disables diagnostics virtual text. I use 'tiny-inline-diagnostic.nvim' instead
				diagnostic_virtual_text = false,

				diagnostic = {
					virtual_text = false,
				},

				-- Disables code action virtual text. I use 'nvim-lightbulb' instead
				code_action = {
					enable = true,
					sign = false,
					sign_priority = 0,
					virtual_text = false,
					virtual_text_icon = false,
				},

				format_on_save = false, -- I use 'conform.nvim' instead

				display_diagnostic_qf = false,
			},

			lsp_signature_help = false, -- I lazy load 'lsp_signature.nvim'

			transparency = 30, -- 0 to 100

			icons = {
				-- Code Lens (gutter, floating window)
				code_lens_action_icon = '🔍',

				-- Diagnostics (gutter)
				diagnostic_head = '󱞪',
				diagnostic_err = '',
				diagnostic_warn = '',
				diagnostic_info = '',
				diagnostic_hint = '',
			},
		},

		config = function(_, opts)
			require('navigator').setup(opts)

			-- Attach navigator to all buffers with a LSP server attached
			vim.api.nvim_create_autocmd('LspAttach', {
				callback = function(args)
					local client = args.data
					local buffer_number = args.buf
					require('navigator.lspclient.mapping').setup({ bufnr = buffer_number, client = client })
				end,
			})
		end,
	},
}
