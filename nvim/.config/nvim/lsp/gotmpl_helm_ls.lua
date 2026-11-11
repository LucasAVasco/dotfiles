-- Go templates LSP server configuration. This is a wrapper around the helm_ls LSP server that disables the yamlls server for gotmpl files.

local config_file = vim.api.nvim_get_runtime_file('lsp/helm_ls.lua', false)[1]
local config = dofile(config_file)

---@type my_configs.LSP.LspServerConfig
local overrides = {
	filetypes = { 'gotmpl' },
	settings = {
		['helm-ls'] = {
			yamlls = {
				enabled = false,
			},
		},
	},
}

config = vim.tbl_deep_extend('force', config, overrides)

return config
