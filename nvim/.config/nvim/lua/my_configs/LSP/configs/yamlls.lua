---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
---@diagnostic disable-next-line: missing-fields
local Config = {
	settings = {
		yaml = {
			schemas = require('my_plugin_libs.yamlls.schema'),

			schemaStore = {
				-- Disables the default schema store (use `schemastore.nvim` instead)
				enable = false,
				url = '',
			},
		},
	},
}

return Config
