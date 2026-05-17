return {
	{
		'LucasAVasco/project_runtime_dirs.nvim',
		priority = 100000,

		config = function(opts)
			require('project_runtime_dirs').setup(opts)
			local api_project = require('project_runtime_dirs.api.project')

			-- Adds project spell file

			local project_config_dir = api_project.get_project_configuration_directory()
			if project_config_dir then
				vim.opt.spellfile:prepend(project_config_dir .. 'spell_adds/main.UTF-8.add')
			end
		end,
	},
}
