local schemastore = require('schemastore')

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	settings = {
		---@diagnostic disable-next-line: missing-fields
		json = {
			validate = { enable = true },
			schemas = schemastore.json.schemas(),
		},
	},
}

return Config
