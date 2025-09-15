local vue_ls_config_file = vim.api.nvim_get_runtime_file('lsp/vue_ls.lua', false)[1]
local vue_ls_config = dofile(vue_ls_config_file)

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	on_init = vue_ls_config.on_init,
}

return Config
