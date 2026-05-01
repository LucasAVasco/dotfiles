---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	settings = {
		['helm-ls'] = {
			yamlls = {
				enabledForFilesGlob = '*.{yaml,yml,yaml.gotmpl,yml.gotmpl,tpl}',
				config = {
					schemas = require('my_plugin_libs.yamlls.schema'),
				},
			},
		},
	},
}

return Config
