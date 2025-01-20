--[[ autodoc
	====================================================================================================
	Comment mappings (Plugin)[maps]                                               *plugin-comments-maps*

	`gc` Toggle comment of a line or block of code.
	`gb` Like `gc`, but applies a block comment

	`gd{a,c,f,t}` Generate documentation for the current archive, class, function or type
]]

-- `ts_context_commentstring` integration with `comment.nvim`. This function will be queried and called in `Comment.nvim` pre_hook function
local ts_context_commentstring_pre_hook = nil

return {
	{
		'JoosepAlviste/nvim-ts-context-commentstring',
		lazy = true, -- Loaded in `Comment.nvim`

		opts = {
			enable_autocmd = false,
		},
	},
	{
		'numToStr/Comment.nvim',

		dependencies = {
			'JoosepAlviste/nvim-ts-context-commentstring',
		},

		keys = {
			'gcc',
			'gbb',
			'gcO',
			'gco',
			'gcA',
			{ 'gc', mode = { 'n', 'x' } },
			{ 'gb', mode = { 'n', 'x' } },
		},

		opts = {
			ignore = '^$', -- Ignores empty lines, so the user can move between the commented lines with '{' and '}'

			---Function called before any comment operation
			---@module 'Comment.utils'
			---@param context CommentCtx Context of the comment operation. See the 'Comment.utils' module for further information
			pre_hook = function(context)
				if ts_context_commentstring_pre_hook == nil then
					ts_context_commentstring_pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
				end

				ts_context_commentstring_pre_hook(context)
			end,

			---Function called after any comment operation
			---@module 'Comment.utils'
			---@param context CommentCtx Context of the comment operation. See the 'Comment.utils' module for further information
			post_hook = function(context)
				local start_line = context.range.srow - 1
				local end_line = context.range.erow

				-- Removes white spaces errors. The `padding` option of `Comment.nvim` adds a space between the comment string and the
				-- commented text. I like this feature, but it result in white space errors if the commented text has tabs. To avoid white
				-- space errors, this hook replaces the generated spaces by tabs if they are applied before a tab character
				if context.cmode == 1 then -- When commenting a text
					local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, true)

					---@type string[]
					local response = {}

					for _, line in pairs(lines) do
						local fixed_line = line:gsub(' \t', '\t\t')
						table.insert(response, fixed_line)
					end

					vim.api.nvim_buf_set_lines(0, start_line, end_line, true, response)
				end
			end,
		},
	},
	{
		'danymat/neogen',

		dependencies = {
			'L3MON4D3/LuaSnip',
		},

		cmd = 'Neogen',

		keys = {
			{
				'<leader>da',
				'<CMD>Neogen file<CR>',
				desc = 'Generate archive documentation',
				{ silent = true, remap = false },
			},
			{
				'<leader>dc',
				'<CMD>Neogen class<CR>',
				desc = 'Generate class documentation',
				{ silent = true, remap = false },
			},
			{
				'<leader>df',
				'<CMD>Neogen func<CR>',
				desc = 'Generate function documentation',
				{ silent = true, remap = false },
			},
			{
				'<leader>dt',
				'<CMD>Neogen type<CR>',
				desc = 'Generate type documentation',
				{ silent = true, remap = false },
			},
		},

		opts = {
			snippet_engine = 'luasnip',
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('gd', 'Generate documentation')
		end,
	},
	{
		'folke/todo-comments.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
		},

		opts = {
			keywords = {
				-- Add a keyword to mark content that should not be pushed to a remote repository
				NOPUSH = {
					icon = '󱃆',
					color = 'error',
				},
			},

			highlight = {
				-- Pattern used to highlight the TODO keyword. It is a Vim regex. The official documentation does not explains how to
				-- customize this regex, so I checked the source code (at commit 74abcc81254feee74aa129c0a219750686ebcefd). The method that
				-- implements the match system is the `M.match()` at the 'lua/todo-comments/highlight.lua' file.
				--
				-- This pattern is `very magic` and `case insensitive`. See `:h \v` and `:h \C` for further information. It will be used in
				-- the `vim.fn.matchlist()` function, that returns a list (table in Lua) with the following content:
				--
				-- * first element: full matched text
				--
				-- * second and next elements: sub-matches of the full match, in the order that they are found in the string: \1, \2, and so
				-- on
				--
				-- The first sub-match (second element) is the content that will be highlighted. The second sub-match (third element) must
				-- be the keyword (INFO, FIX, etc.). If there are not a second sub-match, the first will be used as the keyword
				--
				-- The following modification allows to add the author of the TODO between parenthesis after the TODO keyword. This is used
				-- by `ruff` as described in the TD002 rule (https://docs.astral.sh/ruff/rules/missing-todo-author/). But can be used in
				-- languages other than Python. Example:
				--
				-- INFO(LucasAVasco): my INFO comment
				--
				-- The first sub-match will match the keyword and author between parenthesis if provided. So it will also be highlighted.
				-- `(\(.{-}\))?` matches, optionally, anything between parenthesis (less as possible) and the parenthesis itself. The second
				-- sub-match is defined by `(KEYWORDS)`. It will return the keyword required by `todo-comments`
				pattern = [[.*((KEYWORDS)(\(.{-}\))?)\s*:]],
			},

			search = {
				args = {
					'--no-config', -- Does not applies the user configurations to the `rg` command. Avoids breaking search behavior
					'--hidden', -- Search within hidden files and folders. Does not apply to ignored files (E.g. Ignored by Git)
					'--iglob=!.git', -- Ignore '.git' folders. Otherwise, the '--hidden' argument allows to search within it

					-- `todo-comments.nvim` requires these arguments to work properly
					'--no-heading',
					'--column',
				},

				-- Pattern used by Ripgrep (https://github.com/BurntSushi/ripgrep) to search by TODO comments occurrences in the files. Used
				-- by the following commands: `TodoQuickFix`, `TodoLocList`, `TodoTelescope` and `Trouble todo`. This regex is not used to
				-- highlight the occurrences on the viewer (E.g. Telescope). The `highlight.pattern` option is used to this
				--
				-- It is a rust regex (https://docs.rs/regex/latest/regex/)
				--
				-- The following modification allows to add the author of the TODO between parenthesis after the TODO keyword. This is used
				-- by `ruff` as described in the TD002 rule (https://docs.astral.sh/ruff/rules/missing-todo-author/). But can be used in
				-- languages other than Python. Example:
				--
				-- INFO(LucasAVasco): my INFO comment
				--
				-- `(\(.*\))?` matches, optionally, everything between parenthesis and the parenthesis itself. `\b` matches a word boundary
				-- (position between a word and a non-word match)
				pattern = [[\b(KEYWORDS)(\(.*\))?\s*:]],
			},
		},

		init = function()
			MYPLUGFUNC.load_telescope_extension('todo-comments', { 'todo-comments', 'todo' })
		end,
	},
}
