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
			'LucasAVasco/project_runtime_dirs.nvim', -- Used by `TSEditQueryRtd`
		},

		build = ':TSUpdate',

		---@module 'nvim-treesitter.configs'
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			-- 'markdown_inline' is required by `trouble.nvim`. `regex` is required by `noicenvim`
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown_inline', 'regex' },
			sync_install = false,
			auto_install = true, -- Install missing parser when entering a buffer that requires it

			highlight = { enable = true },
			incremental_selection = { enable = true },
			matchup = { enable = true },
			indent = {
				enable = true,
				disable = { 'markdown' },
			},

			-- Text object key maps (used by 'nvim-treesitter-textobjects' plugin) {{{

			-- Configuration based on the official documentation at: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
			-- And on the following video: https://www.youtube.com/watch?v=CEMPq_r8UYQ

			textobjects = {
				select = {
					enable = true,
					lookahead = true,

					keymaps = {
						['i='] = { query = '@assignment.inner', desc = 'Inner assignment' },
						['a='] = { query = '@assignment.outer', desc = 'Outer assignment' },
						['l='] = { query = '@assignment.lhs', desc = 'Left part of assignment' },
						['r='] = { query = '@assignment.rhs', desc = 'Right part of assignment' },
						['ih'] = { query = '@attribute.inner', desc = 'Inner attribute' },
						['ah'] = { query = '@attribute.outer', desc = 'Outer attribute' },
						['ik'] = { query = '@block.inner', desc = 'Inner part of a block' },
						['ak'] = { query = '@block.outer', desc = 'Outer part of a block' },
						['if'] = { query = '@call.inner', desc = 'Inner part of a call' },
						['af'] = { query = '@call.outer', desc = 'Outer part of a call' },
						['i]'] = { query = '@class.inner', desc = 'Inner part of a class' },
						['a]'] = { query = '@class.outer', desc = 'Outer part of a class' },
						['ig'] = { query = '@comment.inner', desc = 'Inner part of comment' },
						['ag'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
						['ii'] = { query = '@conditional.inner', desc = 'Inner part of conditional' },
						['ai'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
						['ie'] = { query = '@frame.inner', desc = 'Inner part of a frame' },
						['ae'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
						['im'] = { query = '@function.inner', desc = 'Inner part of a method/function' },
						['am'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
						['io'] = { query = '@loop.inner', desc = 'Inner part of a loop' },
						['ao'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
						['in'] = { query = '@number.inner', desc = 'Inner part of a number' },
						['iv'] = { query = '@parameter.inner', desc = 'Inner part of a parameter' },
						['av'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
						['ix'] = { query = '@regex.inner', desc = 'Inner part of a regex' },
						['ax'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
						['ir'] = { query = '@return.inner', desc = 'Inner part of a return' },
						['ar'] = { query = '@return.outer', desc = 'Outer part of a return' },
						['ij'] = { query = '@scopename.inner', desc = 'Inner part of a scope name' },
						['aj'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
					},
				},

				swap = {
					enable = true,

					swap_previous = {
						['<A-N>'] = '@parameter.inner',
					},

					swap_next = {
						['<A-n>'] = '@parameter.inner',
					},
				},

				move = {
					enable = true,
					set_jumps = true,

					goto_next_start = {
						[']='] = { query = '@assignment.outer', desc = 'Outer assignment' },
						[']h'] = { query = '@attribute.outer', desc = 'Outer attribute' },
						[']k'] = { query = '@block.outer', desc = 'Outer part of a block' },
						[']f'] = { query = '@call.outer', desc = 'Outer part of a call' },
						[']]'] = { query = '@class.outer', desc = 'Outer part of a class' },
						[']g'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
						[']i'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
						[']e'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
						[']m'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
						[']o'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
						[']n'] = { query = '@number.inner', desc = 'Inner part of a number' },
						[']v'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
						[']x'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
						[']r'] = { query = '@return.outer', desc = 'Outer part of a return' },
						[']j'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
					},

					goto_next_end = {
						[']+'] = { query = '@assignment.outer', desc = 'Outer assignment' },
						[']H'] = { query = '@attribute.outer', desc = 'Outer attribute' },
						[']K'] = { query = '@block.outer', desc = 'Outer part of a block' },
						[']F'] = { query = '@call.outer', desc = 'Outer part of a call' },
						[']['] = { query = '@class.outer', desc = 'Outer part of a class' },
						[']G'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
						[']I'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
						[']E'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
						[']M'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
						[']O'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
						[']V'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
						[']X'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
						[']R'] = { query = '@return.outer', desc = 'Outer part of a return' },
						[']J'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
					},

					goto_previous_start = {
						['[='] = { query = '@assignment.outer', desc = 'Outer assignment' },
						['[h'] = { query = '@attribute.outer', desc = 'Outer attribute' },
						['[k'] = { query = '@block.outer', desc = 'Outer part of a block' },
						['[f'] = { query = '@call.outer', desc = 'Outer part of a call' },
						['[]'] = { query = '@class.outer', desc = 'Outer part of a class' },
						['[g'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
						['[i'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
						['[e'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
						['[m'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
						['[o'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
						['[n'] = { query = '@number.inner', desc = 'Inner part of a number' },
						['[v'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
						['[x'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
						['[r'] = { query = '@return.outer', desc = 'Outer part of a return' },
						['[j'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
					},

					goto_previous_end = {
						['[+'] = { query = '@assignment.outer', desc = 'Outer assignment' },
						['[H'] = { query = '@attribute.outer', desc = 'Outer attribute' },
						['[K'] = { query = '@block.outer', desc = 'Outer part of a block' },
						['[F'] = { query = '@call.outer', desc = 'Outer part of a call' },
						['[['] = { query = '@class.outer', desc = 'Outer part of a class' },
						['[G'] = { query = '@comment.outer', desc = 'Outer part of a comment' },
						['[I'] = { query = '@conditional.outer', desc = 'Outer part of a conditional' },
						['[E'] = { query = '@frame.outer', desc = 'Outer part of a frame' },
						['[M'] = { query = '@function.outer', desc = 'Outer part of a method/function' },
						['[O'] = { query = '@loop.outer', desc = 'Outer part of a loop' },
						['[V'] = { query = '@parameter.outer', desc = 'Outer part of a parameter' },
						['[X'] = { query = '@regex.outer', desc = 'Outer part of a regex' },
						['[R'] = { query = '@return.outer', desc = 'Outer part of a return' },
						['[J'] = { query = '@statement.outer', desc = 'Outer part of a statement' },
					},
				},
			},

			-- }}}
		},

		config = function(_, opts)
			require('mason') -- Configured in another file
			MYPLUGFUNC.ensure_mason_package_installed('tree-sitter-cli') -- Required to use `:TSInstallFromGrammar`

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
		end,
	},
	{
		'Wansmer/treesj',
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},

		cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },

		keys = {
			{
				'<leader>sb',
				function()
					require('treesj').split()
				end,
				desc = 'Split a block (tree-sj)',
			},
			{
				'<leader>j',
				function()
					require('treesj').join()
				end,
				desc = 'Join a block (tree-sj)',
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
			'LucasAVasco/project_runtime_dirs.nvim', -- Used to query the project directory and some configurations
		},

		cmd = { 'LspInjectionsEnable' },

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
		end,
	},
	{
		'lukas-reineke/headlines.nvim',

		dependencies = 'nvim-treesitter/nvim-treesitter',

		ft = { 'markdown', 'norg', 'org' },

		opts = {},
	},
}
