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
