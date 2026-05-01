local catalog = require('schemastore.catalog')
local schemastore = require('schemastore')

---Create a schema that extends another schema with additional file matches
---@param schema_name string The name of the schema to extend
---@param matches string[] The file matches to append to the schema
---@return SchemaEntry?
local function extend_schema(schema_name, matches)
	local index = catalog.json.index[schema_name]
	if index == nil then
		vim.notify('Schema not found: ' .. schema_name, vim.log.levels.ERROR)
		return
	end

	local schema = vim.deepcopy(catalog.json.schemas[index])
	MYFUNC.array_concat(schema.fileMatch, matches)
	return schema
end

local schemas = schemastore.json.schemas({
	extra = {
		extend_schema('VSCode Code Snippets', { 'vscode_snippets/*/*.json' }),
	},
})

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	settings = {
		---@diagnostic disable-next-line: missing-fields
		json = {
			validate = { enable = true },
			schemas = schemas,
		},
	},
}

return Config
