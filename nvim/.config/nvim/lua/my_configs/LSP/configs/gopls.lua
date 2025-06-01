---@module "my_configs.LSP.types"
---@type MyLspServerConfig
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
