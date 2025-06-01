---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	settings = {
		gopls = {
			['ui.inlayhint.hints'] = {
				compositeLiteralFields = true,
				constantValues = true,
				parameterNames = true,
			},
		},
	},
}

return Config
