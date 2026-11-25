return {
	---These file types will overridden the list of associated file types of the LSP servers.
	---@type table<string, string[]|'*'> Relates the LSP server identifier (used by lspconfig) to its overridden file types
	override = {
		gopls = { 'go', 'gomod', 'gowork' }, -- Remove 'gotmpl' file type. I use other LSP for Go templates
	},

	---These file types will be added to the list of associated file types of the LSP servers.
	---@type table<string, string[]|'*'> Relates the LSP server identifier (used by lspconfig) to its extended file types
	extend = {
		bashls = { 'zsh' },
		vtsls = {
			'vue', -- Load when opening Vue files, required by 'vue_ls' plugin
		},

		yamlls = {
			'yaml.github', -- Edit with custom GitHub action file type
		},
	},
}
