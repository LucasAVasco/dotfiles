MYFUNC.call_if_before_editor_config(function()
	vim.bo.expandtab = true
	vim.bo.tabstop = 2
end)

vim.keymap.set('n', '<CR>', function()
	local file_path = vim.api.nvim_buf_get_name(0)
	local file_base_name = vim.fn.fnamemodify(file_path, ':t:r')
	local top_dir_basename = vim.fn.fnamemodify(file_path, ':h:t:r')

	-- New query that overwrites the old one
	local lang = top_dir_basename
	local query_name = file_base_name
	local query_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
	vim.treesitter.query.set(lang, query_name, query_text)

	-- Reload all buffers
	local file_types = vim.treesitter.language.get_filetypes(lang)
	for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
		if vim.treesitter.highlighter.active[buffer] and vim.tbl_contains(file_types, vim.bo[buffer].filetype) then
			vim.treesitter.stop(buffer)
			vim.treesitter.start(buffer)
		end
	end

	-- Notification
	vim.notify(('Query applied for language "%s" and query "%s"'):format(lang, query_name), vim.log.levels.INFO, { title = 'Tree-sitter' })
end, { buffer = true, desc = 'Apply query' })
