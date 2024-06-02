--[[ autodoc
	====================================================================================================
	Alignment mappings (Plugin)[maps]                                            *plugin-alignment-maps*

	`<leader>ga`  Align text by delimiter.

	Shortcuts~

	`<CTrl-P>`  Enter and exit interactive mode.

	Shortcuts (interactive mode)~

	`<Ctrl-G>`     Switch the ignore group option.
	`<Backspace>`  remove the last delimiter and try another one. Repeat the delimiter to apply the changes.
]]


return {
	{
		'junegunn/vim-easy-align',

		keys = {
			{ '<leader>ga', '<Plug>(EasyAlign)', mode = {'n', 'x'}, desc = 'EasyAlign' },
		},

		init = function()
			vim.g.easy_align_ignore_unmatched = 1  -- Ignore lines with out delimiters
		end,
	}
}
