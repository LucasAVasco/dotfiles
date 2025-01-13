-- User command to set the virtual edit mode (local to the window)
vim.api.nvim_create_user_command('SetVirtualEdit', function(arguments)
	vim.opt_local.virtualedit = arguments.fargs[1]
end, {
	nargs = 1,
	complete = MYFUNC.create_complete_function({
		'all',
		'block',
		'insert',
		'none',
		'onemore',
	}),
})
