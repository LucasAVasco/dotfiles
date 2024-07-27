return {
	{
		'nvim-treesitter/nvim-treesitter',

		dependencies = {
			'LucasAVasco/project_runtime_dirs.nvim'  -- Used by `TSEditQueryRtd`
		},

		build = ':TSUpdate',

		opts = {
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown_inline' },  -- 'markdown_inline' is required to the new `Trouble` version
			sync_install = false,
			auto_install = true,  -- Install missing parser when entering a buffer that requires it

			highlight = { enable = true },
			incremental_selection = { enable = true },
			indent = { enable = true },
			matchup = { enable = true },
		},

		config = function(_, opts)
			require('mason')  -- Configured in another file
			MYPLUGFUNC.ensure_mason_package_installed('tree-sitter-cli')  -- Required to use `:TSInstallFromGrammar`

			require('nvim-treesitter.configs').setup(opts)

			-- User command to edit a Tree-sitter query file in a project runtime directory
			vim.api.nvim_create_user_command('TSEditQueryRtd', function(arguments)
				local query_name = arguments.fargs[1]
				local query_folder = 'queries/' .. vim.bo.filetype .. '/'

				require('project_runtime_dirs.api.project.enabled_rtd').select_by_name(function(rtd)
					rtd:edit(query_folder .. query_name .. '.scm', true)
				end)

			end, {
				desc = 'Edit a Tree-sitter query file in a project runtime directory',
				nargs = 1,
				complete = MYFUNC.create_complete_function({
					'folds',
					'highlights',
					'indents',
					'injections',
					'locals',
					'matchup',
				}),
			})
		end
	}
}
