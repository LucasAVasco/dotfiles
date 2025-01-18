local whitespace_error_group = vim.api.nvim_create_augroup('WhitespaceErrorGroup', { clear = true })

local ignore_filetypes = {
	['dbout'] = true,
}

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufNewFile' }, {
	group = whitespace_error_group,
	callback = function(arguments)
		local buffer_nr = arguments.buf
		local window_id = MYFUNC.get_window_by_buffer(buffer_nr)

		-- Only adds the matches to normal buffers (bufftype == '')
		if vim.bo[buffer_nr].buftype ~= '' then
			return
		end

		-- The filetype will be text, c, cpp, editable files. If Neovim is started without a file, this option will be empty and the matches
		-- will not be added. This prevents the matches from being added to the start screen, but requires that the user provides a file to
		-- edit. Otherwise, the matches will not be added
		local filetype = vim.bo[buffer_nr].filetype
		if filetype == '' then
			return
		end

		-- Ignore some filetypes
		if ignore_filetypes[filetype] then
			return
		end

		-- Only adds the matches one time per window
		if vim.w[window_id].__whitespace_error_loaded then
			return
		else
			vim.w[window_id].__whitespace_error_loaded = true
		end

		local priority = 1000
		local match_config = {
			window = window_id,
		}
		vim.fn.matchadd('WhitespaceError', [[\s\+$]], priority, -1, match_config) -- Spaces at the end of line
		vim.fn.matchadd('WhitespaceError', [[\ \+\t]], priority, -1, match_config) -- Spaces before tabs
	end,
})

--- Updates the 'WhitespaceError' highlight group over the active color scheme
local function update_highlight_group()
	-- Shows whitespace errors in red
	vim.api.nvim_set_hl(0, 'WhitespaceError', {
		bg = 'red',
		ctermbg = 'red',
	})
end

update_highlight_group()

-- Creates an auto-command to update the highlight group when the color scheme is changed
vim.api.nvim_create_autocmd({ 'ColorScheme' }, {
	group = whitespace_error_group,
	callback = update_highlight_group,
})
