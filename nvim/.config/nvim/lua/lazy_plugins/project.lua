return {
	{
		'folke/neoconf.nvim',
		main = 'neoconf',

		cmd = 'Neoconf',

		priority = 8500, -- Configuration system

		opts = {
			plugins = {
				jsonls = {
					configured_servers_only = false,
				},

				lua_ls = {
					enabled = true,
				},
			},

			-- Configuration files with C like comments
			global_settings = 'neoconf.jsonc',
			local_settings = '.neoconf.jsonc',
		},
	},
	{
		'LucasAVasco/project_runtime_dirs.nvim',
		priority = 10500,

		config = function(opts)
			require('project_runtime_dirs').setup(opts)
			local api_project = require('project_runtime_dirs.api.project')

			-- Adds project spell file

			local project_config_dir = api_project.get_project_configuration_directory()
			if project_config_dir then
				vim.opt.spellfile:append(project_config_dir .. 'spell_adds/main.UTF-8.add')
			end
		end,
	},
}
