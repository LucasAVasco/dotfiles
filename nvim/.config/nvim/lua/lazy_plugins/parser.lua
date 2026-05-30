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

--- Starts the tree-sitter parser in the buffer. Does nothing if the parser is already running or if the buffer does not have a available
--- parser
---@param buffer integer
local function enable_highlighting(buffer)
	if not require('my_plugin_libs.treesitter').buffer_has_parser(buffer) then
		return
	end

	if vim.treesitter.highlighter.active[buffer] then
		return
	end

	vim.treesitter.start(buffer)
end

--- Stops the tree-sitter parser in the buffer. Does nothing if the parser is not running
---@param buffer integer
local function disable_highlighting(buffer)
	if vim.treesitter.highlighter.active[buffer] then
		vim.treesitter.stop(buffer)
	end
end

--- List of languages already installed (do not install them again)
---@type { [string]: boolean }
local already_installed = {}

--- Returns the languages that are not installed
---@param langs string[]
---@return string[]
local function filter_non_installed_langs(langs)
	local installed = {}
	for _, lang in pairs(langs) do
		if not already_installed[lang] then
			table.insert(installed, lang)
		end
	end
	return installed
end

--- Mark the languages as already installed
---@param langs any
local function mark_langs_as_installed(langs)
	for _, lang in pairs(langs) do
		already_installed[lang] = true
	end
end

--- Return the treesitter languages that are inside the current buffer. Example: current language + injected languages
---
--- ***NOTE***: automatically starts the tree-sitter parser in the buffer if it is not running
---@param buffer integer
---@return string[]
local function get_buffer_languages(buffer)
	-- Current parser
	local parser, err = vim.treesitter.get_parser(buffer, nil, {
		error = false,
	})
	if err then
		vim.notify('error getting parser: ' .. err, vim.log.levels.ERROR)
		return {}
	end

	if parser == nil then
		return {}
	end

	-- Languages in the current parser
	local inner_langs = {}
	parser:for_each_tree(function(_, ltree)
		local lang = ltree:lang()
		table.insert(inner_langs, lang)
	end)

	return inner_langs
end

--- Install the parsers for the given languages and starts tree-sitter in the provided buffer
---@param langs? string[]
---@param buffer integer
local function setup_parsers(buffer, langs)
	if not require('my_plugin_libs.treesitter').buffer_has_parser(buffer) then
		return
	end

	-- Default language
	if langs == nil then
		langs = {
			vim.treesitter.language.get_lang(vim.bo[buffer].filetype),
		}
	end

	--- List languages to install
	---@type string[]
	local langs_to_install = filter_non_installed_langs(langs)

	-- Only install once. All languages even if they does not have a parser are marked as installed to avoid running this function again
	mark_langs_as_installed(langs)

	-- No parser to install, just start tree-sitter
	if #langs_to_install == 0 then
		enable_highlighting(buffer)
		return
	end

	--- Installs the parsers
	local task = require('nvim-treesitter').install(langs_to_install)

	-- Wait for the languages to be installed before installing its inner languages
	task:await(function(err)
		if err then
			vim.notify('error installing parsers: ' .. vim.inspect(err), vim.log.levels.ERROR)
			return
		end

		-- Install inner languages
		local all_langs = get_buffer_languages(buffer)
		disable_highlighting(buffer) -- Disable highlighting to ensure that the new parsers are loaded by the next setup function
		setup_parsers(buffer, all_langs)
	end)
end

return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',

		dependencies = {
			'LucasAVasco/project_runtime_dirs.nvim', -- Used by `TSEditQueryRtd`
		},

		build = ':TSUpdate',

		---@module 'nvim-treesitter.configs'
		---@type TSConfig
		---@diagnostic disable-next-line: missing-fields
		opts = {
			-- 'markdown_inline' is required by `trouble.nvim`. `regex` is required by `noicenvim`, 'diff' is required by 'gitcommit'
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown_inline', 'regex', 'diff' },
		},

		config = function(_, opts)
			require('mason') -- Configured in another file
			local treesitter = require('nvim-treesitter')
			treesitter.setup(opts)

			MYPLUGFUNC.ensure_mason_package_installed('tree-sitter-cli') -- Required to use `:TSInstallFromGrammar`
			treesitter.install(opts.ensure_installed)

			-- Auto command to automatically enable tree-sitter syntax highlighting to all buffers with an available parser. Automatically
			-- detect and install the parser if needed
			vim.api.nvim_create_autocmd('FileType', {
				callback = function(args)
					setup_parsers(args.buf)
				end,
			})

			-- Dedent tree-sitter injections
			require('my_plugins.dedent_ts_injections').setup()

			-- User commands

			local complete_function = MYFUNC.create_complete_function({
				'folds',
				'highlights',
				'indents',
				'injections',
				'locals',
				'matchup',
			})

			---Get the sub path of the tree-sitter query file of the current buffer
			---@param buffer integer
			---@param query_name string
			---@return string sub_path Matches the following format 'queries/{lang}/{query_name}.scm'
			local function get_buffer_query_sub_path(buffer, query_name)
				local lang = vim.treesitter.language.get_lang(vim.bo[buffer].filetype)

				return 'queries/' .. lang .. '/' .. query_name .. '.scm'
			end

			vim.api.nvim_create_user_command('TSEditQueryConfig', function(args)
				vim.cmd.edit({ args = { MYPATHS.config .. get_buffer_query_sub_path(0, args.fargs[1]) } })
			end, {
				desc = 'Edit a Tree-sitter query file at configuration directory',
				nargs = 1,
				complete = complete_function,
			})

			vim.api.nvim_create_user_command('TSEditQueryRtd', function(arguments)
				local sub_path = get_buffer_query_sub_path(0, arguments.fargs[1])

				local enabled_rtd = require('project_runtime_dirs.api.project.enabled_rtd')
				if #enabled_rtd.get_all() == 0 then
					vim.notify('No runtime directories enabled', vim.log.levels.WARN, { title = 'Tree-sitter' })
					return
				end

				enabled_rtd.select_by_name(function(rtd)
					if rtd ~= nil then
						rtd:edit(sub_path, true)
					end
				end)
			end, {
				desc = 'Edit a Tree-sitter query file in a project runtime directory',
				nargs = 1,
				complete = complete_function,
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

		cond = MYVAR.not_in_vscode,

		ft = { 'norg', 'org' },

		opts = {
			markdown = { query = false },
		},
	},
}
