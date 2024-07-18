--[[ autodoc
	====================================================================================================
	Comment mappings (Plugin)[maps]                                               *plugin-comments-maps*

	`<leader>cc` Comment a line or block of code.
	`<leader>cu` remove the comment of a line or block of code.

	To change the comment style (if available), use the `<leader>ca` command.

	To comment at the end of the line, use the `<leader>cA` command.
]]


return {
	{
		'preservim/nerdcommenter',

		keys = {
			{ '<leader>c', mode = {'n', 'v'}, desc = 'Nerdcommenter maps' },
		},

		init = function()
			vim.cmd('filetype plugin on')
			vim.g.NERDSpaceDelims = 1
			vim.g.NERDTrimTrailingWhitespace = 1 -- Remove trailing spaces after remove a comment
			vim.g.NERDDefaultAlign = 'left'
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
				}
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
					'--no-config',    -- Does not applies the user configurations to the `rg` command. Avoids breaking search behavior
					'--hidden',       -- Search within hidden files and folders. Does not apply to ignored files (E.g. Ignored by Git)
					'--iglob=!.git',  -- Ignore '.git' folders. Otherwise, the '--hidden' argument allows to search within it

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
			}
		},

		init = function()
			MYPLUGFUNC.load_telescope_extension('todo-comments', { 'todo-comments', 'todo' })
		end
	}
}
