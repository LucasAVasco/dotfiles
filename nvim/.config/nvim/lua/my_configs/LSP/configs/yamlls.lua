local schemastore = require('schemastore')
local schemas = schemastore.yaml.schemas()

-- Configure the patterns for kubernetes files

schemas.kubernetes = {
	'templates/**', -- Helm templates
	'k8s/*.yaml',
	'k8s-*.yaml',
	'k3s/*.yaml',
	'k3s-*.yaml',
	'k8s/*.yml',
	'k8s-*.yml',
	'k3s/*.yml',
	'k3s-*.yml',

	-- Editing an existing instance with `kubectl edit`
	'kubectl-edit-*.yaml',
	'kubectl-edit-*.yml',
}

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
---@diagnostic disable-next-line: missing-fields
local Config = {
	settings = {
		yaml = {
			schemas = schemas,

			schemaStore = {
				-- Disables the default schema store (use `schemastore.nvim` instead)
				enable = false,
				url = '',
			},
		},
	},
}

return Config
