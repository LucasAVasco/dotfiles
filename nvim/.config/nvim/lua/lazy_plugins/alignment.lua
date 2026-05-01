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

		cmd = {
			'EasyAlign',
			'LiveEasyAlign',

			-- My commands
			'EasyAlignNoIgnore',
			'LiveEasyAlignNoIgnore',
		},

		keys = {
			{ '<CR>', '<Plug>(LiveEasyAlign)', mode = 'x', desc = 'LiveEasyAlign' },
			{ '<leader>ga', '<Plug>(EasyAlign)', mode = { 'n', 'x' }, desc = 'EasyAlign' },
		},

		init = function()
			vim.g.easy_align_ignore_unmatched = 1 -- Ignore lines with out delimiters
		end,

		config = function(_, _)
			---Creates an alias for an easy_align command without `easy_align_ignore_groups`
			---@param command string The easy_align command to alias
			---@param name string The name of the alias
			local function create_easy_align_alias_without_ignore_group(command, name)
				vim.api.nvim_create_user_command(name, function(args)
					local backup_group = vim.g.easy_align_ignore_groups
					vim.g.easy_align_ignore_groups = {}
					vim.cmd({ cmd = command, args = args.fargs, bang = args.bang, range = { args.line1, args.line2 } })
					vim.g.easy_align_ignore_groups = backup_group
				end, { nargs = '*', range = true, bang = true })
			end

			create_easy_align_alias_without_ignore_group('EasyAlign', 'EasyAlignNoIgnore')
			create_easy_align_alias_without_ignore_group('LiveEasyAlign', 'LiveEasyAlignNoIgnore')
		end,
	},
}
