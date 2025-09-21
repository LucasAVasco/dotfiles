vim.api.nvim_create_user_command('ScrollBindToggle', 'set scrollbind!', {
	desc = 'Toggle the scrollbind option of the current window.',
})

vim.api.nvim_create_user_command('AppendFileToClip', function(arguments)
	local file = arguments.fargs[1]
	if file == '%' then
		file = vim.api.nvim_buf_get_name(0)
	end

	vim.system({ 'append-file-clip', file })
end, {
	desc = 'Append a file to the clipboard',
	nargs = 1,
})

vim.keymap.set('n', '<leader>cc', '<CMD>AppendFileToClip %<CR>', { desc = 'Append current file to clipboard' })

vim.api.nvim_create_user_command('PutPath', function(arguments)
	-- Absolute of the current file
	local path = arguments.fargs[1] or vim.fn.expand('%')
	path = vim.fs.abspath(path)

	vim.api.nvim_put({ path }, 'c', true, true)
end, {
	desc = 'Write the current file path',
	nargs = '?',
})

vim.api.nvim_create_user_command('PutDir', function(arguments)
	-- Absolute of the current file
	local path = arguments.fargs[1] or vim.fn.expand('%')
	path = vim.fs.abspath(path)

	-- Gets the parent directory
	path = vim.fs.dirname(path)

	vim.api.nvim_put({ path }, 'c', true, true)
end, {
	desc = 'Write the directory of the current file',
	nargs = '?',
})
