---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = '@vue/typescript-plugin',
						location = MYPATHS.mason_packages .. 'vue-language-server/node_modules/@vue/language-server',
						configNamespace = 'typescript',
						languages = { 'vue' },
					},
				},
			},
		},
	},
}

return Config
