---Table with the server to override and the new file types values
---@type table<string, string[]|string> Relates the LSP server identifier (used by lspconfig) to its override file types
return {
	clangd = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
	ts_ls = {
		-- Default supported files
		'javascript',
		'javascript.jsx',
		'javascriptreact',
		'typescript',
		'typescript.tsx',
		'typescriptreact',

		-- Plugins and extension
		'vue', -- Support Vue plugin
	},
	vtsls = {
		-- Default supported files
		'javascript',
		'javascript.jsx',
		'javascriptreact',
		'typescript',
		'typescript.tsx',
		'typescriptreact',

		-- Plugins and extension
		'vue', -- Support Vue plugin
	},
}
