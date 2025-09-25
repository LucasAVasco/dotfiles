---@module 'my_configs.DAP.types'

local settings = require('my_configs.DAP.settings')

local M = {}

---Get the path to the nvim-dap configuration file of the current project.
---@return string?
function M.get_project_config_file()
	local project_config_dir = require('project_runtime_dirs.api.project').get_project_configuration_directory()

	---@type string?
	local file
	if project_config_dir then
		file = project_config_dir .. '/DAP.lua'
	end

	return file
end

---Get all configurations from the project configuration file.
---@return my_config.DAP.debugee_file
local function get_project_configs()
	local file = M.get_project_config_file()

	-- The file must exist at the configuration folder
	if not file then
		return {}
	end

	-- Should be able to read the file
	if vim.fn.filereadable(file) == 0 then
		vim.notify(
			'Configuration file at "' .. file .. '" is not readable. Check the project configuration directory by it.',
			vim.log.levels.ERROR,
			{
				title = 'DAP',
			}
		)
		return {}
	end

	-- Aborts if the file is not secure
	if not vim.secure.read(file) then
		vim.notify(
			'Configuration file at "' .. file .. '" is not secure. Check the project configuration directory by it and trust the file.',
			vim.log.levels.ERROR,
			{
				title = 'DAP',
			}
		)
		return {}
	end

	-- Configuration returned from the file
	local config = dofile(file)
	if type(config) ~= 'table' then
		vim.notify('Configuration file at "' .. file .. '" does not return a table.', vim.log.levels.ERROR, {
			title = 'DAP',
		})
		return {}
	end
	return config
end

---All debugee configurations should be based on this one.
---@type my_config.DAP.debugee | {}
local base_debugee_config = {
	request = 'launch',
	program = '${file}',
}

---Get the default debugee configuration for a debugger adapter.
---@param adapter string
---@return my_config.DAP.debugee
local function get_default_debugee_for_adapter(adapter)
	local has_config, config = pcall(require, 'my_configs.DAP.configs.debugee.' .. adapter)
	if not has_config then
		config = {
			name = adapter,
			type = adapter,
		}
	end

	return vim.tbl_extend('force', base_debugee_config, config)
end

---Get a list of the default debugee configurations for a specific file type.
---@param file_type string
---@return my_config.DAP.debugee[]
local function get_default_configs_for_file_type(file_type)
	---@type boolean, my_config.DAP.debugee[]
	local has_config, config = pcall(require, 'my_configs.DAP.configs.filetype.' .. file_type)
	if has_config then
		return config
	end

	---Default debugee configurations generated from the default adapters
	config = {}
	local adapters = settings.file_type2adapter[file_type]
	for _, adapter in ipairs(adapters) do
		table.insert(config, get_default_debugee_for_adapter(adapter))
	end

	return config
end

---Check if two debugee configurations have the same name.
---@param config_a my_config.DAP.debugee
---@param config_b my_config.DAP.debugee
---@return boolean
local function configs_has_same_name(config_a, config_b)
	return config_a.name == config_b.name
end

---Get all debugee configurations for a specific file type.
---
---Includes the default configuration and project specific configurations.
---@param file_type string
---@return my_config.DAP.debugee[]
function M.get_file_configs(file_type)
	local default_configs = get_default_configs_for_file_type(file_type)
	local project_configs = get_project_configs()[file_type] or {}

	-- Configurations to return
	local configs = project_configs

	-- Appends the default configuration
	for _, default_config in ipairs(default_configs) do
		local already_exist = MYFUNC.array_has(configs, default_config, configs_has_same_name)

		if not already_exist then
			table.insert(configs, default_config)
		end
	end

	-- Applies the defaults to each configuration
	for i, config in ipairs(configs) do
		local default = get_default_debugee_for_adapter(config.type)

		configs[i] = vim.tbl_deep_extend('force', default, config)
	end

	return configs
end

return M
