---Get the adapter configuration by its name. Only works with adapters configured at '../my_configs/test/adapter/'
---@param name string
---@return neotest.Adapter adapter, string? err
local function get_adapter_configuration(name)
	---@type boolean, neotest.Adapter?
	local ok, adapter = pcall(function()
		return require('my_configs.test.adapter.' .. name)
	end)

	if not ok then
		return {}, 'Can not get configurations of adapter: ' .. name
	end

	return adapter or {}, nil
end

---@class lazy_plugins.test.ConfigFile.Core
---@field adapters string[] Neotest adapters to load.

---@class lazy_plugins.test.ConfigFile.Project: lazy_plugins.test.ConfigFile.Core
---@field path string Root directory of the project.

---@class lazy_plugins.test.ConfigFile
---@field adapters string[] Globally enabled adapters.
---@field projects lazy_plugins.test.ConfigFile.Project[] Projects to load.
local default_config_file = {
	adapters = {},
	projects = {},
}

---@type lazy_plugins.test.ConfigFile
local config_file = {
	adapters = {},
	projects = {},
}

---Get the default neotest configuration
---@return neotest.Config config, string? err
local function get_default_config()
	local config_dir = require('project_runtime_dirs.api.project').get_project_configuration_directory()

	if not config_dir then
		local cwd, err_name, err_message = vim.uv.cwd()
		if not cwd then
			return {},
				('Can not get current working directory (used as configuration directory). Error name: %s. Error Message: %s'):format(
					err_name,
					err_message
				)
		end
		config_dir = cwd
	end

	---@type lazy_plugins.test.ConfigFile|{}
	config_file, _ = MYFUNC.get_json_file_content(config_dir .. 'neotest.json')

	---@type lazy_plugins.test.ConfigFile
	config_file = vim.tbl_extend('force', default_config_file, config_file)

	---@type neotest.Config|{}
	local config = {
		adapters = {},
		projects = {},
	}

	-- Projects must use absolute paths

	local base_dir = require('project_runtime_dirs.api.project').get_project_configuration_directory()
	for _, project in ipairs(config_file.projects) do
		project.path = MYFUNC.absolute_path(project.path, base_dir)
	end

	-- Adds default adapters
	for _, adapter_name in ipairs(config_file.adapters) do
		local adapter, err = get_adapter_configuration(adapter_name)
		if err then
			return {}, ('Can not add "%s" adapter to default adapters: %s'):format(adapter_name, err)
		end
		table.insert(config.adapters, adapter)
	end

	-- Adds project specific adapters
	for _, project_data in ipairs(config_file.projects) do
		---@type neotest.CoreConfig|{}
		local new_project = {
			adapters = {},
		}
		config.projects[project_data.path] = new_project

		if project_data.adapters then
			for _, adapter_name in ipairs(project_data.adapters) do
				local adapter, err = get_adapter_configuration(adapter_name)
				if err then
					return {}, ('Can not add "%s" adapter to project at "%s". Error: %s'):format(adapter_name, project_data.path, err)
				end
				table.insert(new_project.adapters, adapter)
			end
		end
	end

	return config, nil
end

---@type neotest.CoreConfig|{}?
local current_file_project

local function setup_current_buffer_project(buffer_number)
	-- Only configure once
	if current_file_project then
		return
	end

	-- File type of the current buffer
	local filetype = vim.bo[buffer_number].filetype
	local adapters_names = require('my_configs.test.settings').default_adapters[filetype]

	if not adapters_names then -- Current file type is not supported
		return
	end

	-- Configuration of the project that owns the current file
	current_file_project = {
		adapters = {},
	}

	-- Project root directory
	local project_root, err_name, err_message = vim.uv.cwd()
	if not project_root then
		vim.notify(('Can not get current working directory. Error name: %s. Error Message: %s'):format(err_name, err_message))
		return
	end
	project_root = vim.fs.normalize(project_root)

	-- Aborts if there is already a project for the current directory
	for _, project in ipairs(config_file.projects) do
		if project.path == project_root then
			return
		end
	end

	-- Adds the adapters configured to the current buffer
	for _, adapter_name in ipairs(adapters_names) do
		local adapter, err = get_adapter_configuration(adapter_name)
		if err then
			return {}, ('Can not add "%s" adapter to current buffer project at "%s". Error: %s'):format(adapter_name, project_root, err)
		end
		table.insert(current_file_project.adapters, adapter)
	end

	require('neotest').setup_project(project_root, current_file_project)
end

return {
	{
		'nvim-neotest/neotest',

		dependencies = {
			'nvim-neotest/nvim-nio',
			'nvim-lua/plenary.nvim',
			'antoinemadec/FixCursorHold.nvim',
			'nvim-treesitter/nvim-treesitter',

			-- List of runners available at 'https://github.com/nvim-neotest/neotest?tab=readme-ov-file#supported-runners'

			{ 'fredrikaverpil/neotest-golang', version = '*' },
		},

		cmd = 'Test',

		keys = {
			{ '<leader>Trn', '<CMD>Test run near<CR>', desc = 'Run nearest test' },
			{ '<leader>Trf', '<CMD>Test run file<CR>', desc = 'Run file tests' },
			{ '<leader>Tra', '<CMD>Test run all<CR>', desc = 'Run all tests' },
			{ '<leader>Trc', '<CMD>Test run CI<CR>', desc = 'Run all tests (CI mode)' },
			{ '<leader>Twn', '<CMD>Test watch near<CR>', desc = 'Toggle watch mode on nearest test' },
			{ '<leader>Twf', '<CMD>Test watch file<CR>', desc = 'Toggle watch mode on file' },
			{ '<leader>Twa', '<CMD>Test watch all<CR>', desc = 'Toggle watch mode on all tests' },
			{ '<leader>Twc', '<CMD>Test watch CI<CR>', desc = 'Toggle watch mode on all tests (CI mode)' },
			{ '<leader>Td', '<CMD>Test debug<CR>', desc = 'Debug nearest test' },
			{ '<leader>Ts', '<CMD>Test stop<CR>', desc = 'Stop tests' },
			{ '<leader>Th', '<CMD>Test attach<CR>', desc = 'Attach to nearest test' },
			{ '<leader>To', '<CMD>Test show<CR>', desc = 'Show tests output' },
			{ '<leader>Tp', '<CMD>Test panel<CR>', desc = 'Toggle tests panel' },
			{ '<leader>Tm', '<CMD>Test summary<CR>', desc = 'Toggle summary UI' },
			{ '<leader>TT', '<CMD>Test repeat<CR>', desc = 'Repeat last Test command' },
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>T', 'Tests key maps')
		end,

		config = function()
			local neotest = require('neotest')

			local config, err = get_default_config()
			if err then
				vim.notify('[neotest] Error getting default configuration: ' .. err, vim.log.levels.ERROR)
			end
			neotest.setup(config)

			-- Command to manage tests

			---@type fun()
			local last_command_handler
			vim.api.nvim_create_user_command('Test', function(args)
				local current_buffer_project_err = setup_current_buffer_project(0)
				if current_buffer_project_err then
					vim.notify(
						'[Test command] Can not setup the current buffer project: ' .. current_buffer_project_err,
						vim.log.levels.ERROR
					)
				end

				local handler = MYFUNC.get_fargs_handler(args.fargs, {
					['run near'] = neotest.run.run,
					['run file'] = function()
						neotest.run.run(vim.fn.expand('%'))
					end,
					['run all'] = function()
						neotest.run.run({ suite = true })
					end,
					['run CI'] = function()
						neotest.run.run({ suite = true, env = { CI = '1' } })
					end,
					['watch near'] = neotest.watch.toggle,
					['watch file'] = function()
						neotest.watch.toggle(vim.fn.expand('%'))
					end,
					['watch all'] = function()
						neotest.watch.toggle({ suite = true })
					end,
					['watch CI'] = function()
						neotest.watch.toggle({ suite = true, env = { CI = '1' } })
					end,
					['debug'] = function()
						neotest.watch.toggle({ suite = false, strategy = 'dap' })
					end,
					['stop'] = neotest.run.stop,
					['attach'] = neotest.run.attach,
					['show'] = function()
						neotest.output.open({ enter = true, auto_close = true })
					end,
					['panel'] = neotest.output_panel.toggle,
					['summary'] = neotest.summary.toggle,
					['repeat'] = last_command_handler,
				})

				if not handler then
					vim.notify('Unknown command: ' .. args.args, vim.log.levels.ERROR)
					return
				end

				last_command_handler = handler

				handler()
			end, {
				nargs = '+',
				complete = MYFUNC.create_complete_function({
					run = {
						'near',
						'file',
						'all',
						'CI',
					},
					watch = {
						'near',
						'file',
						'all',
						'CI',
					},
					'debug',
					'stop',
					'attach',
					'show',
					'panel',
					'summary',
					'repeat',
				}),
			})
		end,
	},
}
