-- Triggers the 'User MyEventOpenEditableFile' event when the user edits a file. This is useful if you want to lazy load a plugin to start
-- only after the user opens a file to edit
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
	callback = function()
		vim.api.nvim_exec_autocmds('User', {
			pattern='MyEventOpenEditableFile'
		})
	end
})
