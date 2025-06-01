-- Based on the configuration at https://dev.to/danwalsh/solved-vue-3-typescript-inlay-hint-support-in-neovim-53ej

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	init_options = {
		plugins = {
			{
				name = '@vue/typescript-plugin',
				location = MYPATHS.mason_packages .. '/vue-language-server/node_modules/@vue/language-server',
				languages = { 'vue' },
			},
		},
	},
	settings = {},
}

return Config
