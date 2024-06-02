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
			vim.g.NERDCommentEmptyLines = 1
			vim.g.NERDSpaceDelims = 1
			vim.g.NERDTrimTrailingWhitespace = 1 -- Remove trailing spaces after remove a comment
			vim.g.NERDDefaultAlign = 'left'
		end,
	}
}
