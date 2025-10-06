-- Automatically install some software related to the filetype
vim.api.nvim_create_autocmd('FileType', {
	callback = function()
		local auto_install_files = vim.api.nvim_get_runtime_file('lua/my_auto_install/' .. vim.bo.filetype .. '.lua', true)

		for _, file in ipairs(auto_install_files) do
			dofile(file)
		end
	end,
})
