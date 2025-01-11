local schemastore = require('schemastore')

---@module "my_configs.LSP.types"
---@type MyLspServerConfig
local Config = {
	settings = {
		yaml = {
			schemas = schemastore.yaml.schemas(),
			schemaStore = {
				-- Disables the default schema store (use `schemastore.nvim` instead)
				enable = false,
				url = '',
			},
		},
	},
}

return Config
