--[[ autodoc
	====================================================================================================
	AI mappings (Plugin)[maps]                                                          *plugin-ai-maps*

	`<A-1>`     Previous AI completion
	`<A-2>`     Next AI completion
	`<A-Tab>`   Accept AI completion

	====================================================================================================
	AI commands (Plugin)[cmd]                                                       *plugin-ai-commands*

	`CodeiumChat` Open chat with the AI.
]]


return {
	{
		'Exafunction/codeium.vim', branch = 'main',
		name = 'Codeium',

		init = function()
			vim.g.codeium_disable_bindings = 1  -- Disables all default maps
		end,

		config = function()
			options = myfunc.decorator_create_options_table({
				noremap = true,
				silent = true ,
				expr = true  -- Some maps does not work without 'expr = true'
			})

			vim.keymap.set('i', '<A-1>', myfunc.decorator_call_vim_function('codeium#CycleCompletions', {-1}), options('Previous AI completion'))
			vim.keymap.set('i', '<A-2>', myfunc.decorator_call_vim_function('codeium#CycleCompletions', {1}), options('Next AI completion'))
			vim.keymap.set('i', '<A-Tab>', myfunc.decorator_call_vim_function('codeium#Accept', {}), options('Accept AI completion'))

			-- Chat
			vim.api.nvim_create_user_command('CodeiumChat', 'call codeium#Chat()', { desc = 'Open chat with the AI.' })
		end
	}
}
