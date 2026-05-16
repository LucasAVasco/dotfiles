_G.MYVAR = {}
_G.MYPLUGVAR = {}

MYVAR.in_vscode = vim.g.vscode
MYVAR.not_in_vscode = not MYVAR.in_vscode

MYVAR.utilities_ft = {
	'terminal',
	'NvimTree',
	'neo-tree',
	'calendar',
	'guihua',
	'lazy', -- 'lazy.nvim'
	'noice',
	'snacks_picker_input', -- 'snacks.nvim'
	'undotree',
	'qf',
	'trouble',

	-- AI
	'codecompanion',
	'AvanteInput',
	'Avante',
	'AvanteSelectedFiles',

	-- Neotest
	'neotest-summary',
	'neotest-output-panel',

	-- 'Telescope' plugin
	'Telescope',
	'TelescopePrompt',

	-- 'nvim-dap-ui' plugin
	'dap-repl',
	'dapui_breakpoints',
	'dapui_console',
	'dapui_scopes',
	'dapui_stacks',
	'dapui_watches',
}

---You can use this global variable to disable some LSP servers. Add their names (same used by `lspconfig`) to this list before the
---`lspconfig` configuration
---@type string[]
MYVAR.lsp_servers_to_disable = {}

-- Snippets configuration
MYVAR.snippets = {
	-- Helm configurations
	helm = {
		-- Helm helper configurations
		helper = {
			-- Enable snippets related to Helm helper. Replace some snippets to a version that uses the Helm helper
			enabled = false,

			-- Value of the 'app.kubernetes.io/part-of' label
			part_of = 'part-of',

			-- Value of the helper library
			name = 'helm',
		},
	},
}
