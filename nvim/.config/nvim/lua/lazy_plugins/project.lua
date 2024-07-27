return {
	{
		'folke/neoconf.nvim',
		main = 'neoconf',

		priority = 8500,  -- Configuration system

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

		config = true,
	}
}
