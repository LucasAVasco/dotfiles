--[[ autodoc
	====================================================================================================
	Tree-sitter commands [cmd]                                                    *tree-sitter-commands*

	`InspectTree` Shows the Tree-sitter tree. Useful if you want to know the syntax tree to create an
	injection query or something like this.

	`TSEditQuery <query name>` Edit a Tree-sitter query file in the Tree-sitter plugin directory.

	`TSEditQueryUserAfter <query name>` Edit a Tree-sitter query file in the Neovim configuration
	directory.

	`TSEditQueryRtd <query name>` Edit a Tree-sitter query file in a project runtime directory.

	====================================================================================================
	Tree-sitter information [cmd]                                                     *tree-sitter-info*

	Uselful sites: ~

	* https://tree-sitter.github.io/tree-sitter/using-parsers

	* https://tree-sitter.github.io/tree-sitter/syntax-highlighting

	If you are editing a query, these sites may be relevant: ~

	* https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries

	* https://tree-sitter.github.io/tree-sitter/syntax-highlighting#queries

	If you are editing a injection query, this site may be relevant: ~

	* https://tree-sitter.github.io/tree-sitter/syntax-highlighting#language-injection
]]


return {
	{
		'nvim-treesitter/nvim-treesitter',

		dependencies = {
			'LucasAVasco/project_runtime_dirs.nvim'  -- Used by `TSEditQueryRtd`
		},

		build = ':TSUpdate',

		opts = {
			-- 'markdown_inline' is required by `trouble.nvim`. `regex` is required by `noicenvim`
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown_inline', 'regex' },
			sync_install = false,
			auto_install = true,  -- Install missing parser when entering a buffer that requires it

			highlight = { enable = true },
			incremental_selection = { enable = true },
			matchup = { enable = true },
			indent = {
				enable = true,
				disable = { 'markdown' },
			},
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
	},
	{
		'Wansmer/treesj',
		dependencies = {
			'nvim-treesitter/nvim-treesitter'
		},

		cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },

		keys = {
			{
				'<leader>s',
				function()
					require('treesj').split()
				end,
				desc='Split a block (tree-sj)',
			},
			{
				'<leader>j',
				function()
					require('treesj').join()
				end,
				desc='Join a block (tree-sj)',
			},
		},

		opts = {
			use_default_keymaps = false,
		},
	},
	{
		'jmbuhr/otter.nvim',
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
			'LucasAVasco/project_runtime_dirs.nvim'  -- Used to query the project directory and some configurations
		},

		cmd = {'LspInjectionsEnable'},

		opts = {
			lsp = {
				root_dir = function(_, _)
					return require('project_runtime_dirs.api.project').get_project_directory() or vim.fn.getcwd()
				end,
			},

			buffers = {
				set_filetype = true,
				write_to_disk = vim.g.otter_write_to_disk or false,
			},
		},

		config = function(_, opts)
			local otter = require('otter')
			otter.setup(opts)

			vim.api.nvim_create_user_command('LspInjectionsEnable', function()
				otter.activate()
			end, {})
		end
	}
}
