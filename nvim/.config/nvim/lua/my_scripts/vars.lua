_G.MYVAR = {}
_G.MYPLUGVAR = {}

MYVAR.utilities_ft = {
	'NvimTree',
	'calendar',
	'guihua',
	'lazy', -- 'lazy.nvim'
	'noice',
	'snacks_picker_input', -- 'snacks.nvim'
	'undotree',

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
