local schemastore = require('schemastore')

---@type table<string, string[]> Maps the schema URL to its file matches
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

-- Support to 'helmfile.yml.gotmpl' and 'helmfile.yaml.gotmpl'

local helmfile_schema = schemas['https://www.schemastore.org/helmfile.json']
table.insert(helmfile_schema, 'helmfile.yml.gotmpl')
table.insert(helmfile_schema, 'helmfile.yaml.gotmpl')

return schemas
