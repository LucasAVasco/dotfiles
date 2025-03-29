-- Files configurations
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'

-- Backup, undo and swap files
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.swapfile = true

local home_path = vim.env.HOME

vim.fn.system({
	'mkdir',
	'-p',
	home_path .. '/.nvim/.backup_files/',
	home_path .. '/.nvim/.undo_files/',
	home_path .. '/.nvim/.swap_files/',
})
vim.opt.backupdir = home_path .. '/.nvim/.backup_files//'
vim.opt.undodir = home_path .. '/.nvim/.undo_files//'
vim.opt.directory = home_path .. '/.nvim/.swap_files//'

-- Mouse configurations
vim.opt.hidden = true
vim.opt.mouse = 'a'

-- Load the plugin files for specific file types
vim.cmd('filetype plugin on')

-- Load the indent file for specific file types
vim.cmd('filetype indent on')

-- Indentation
vim.opt.expandtab = false -- Expand tabs to spaces convert tabs to spaces
vim.opt.smarttab = false -- The smarttab option change how to use the 'tabstop', 'softtabstop' and 'shiftwidth'options
vim.opt.tabstop = 4 -- Number of spaces that a Tab represents
vim.opt.softtabstop = -1 -- Number of spaces added for Tab when editing ( <0 = use 'shiftwidth')
vim.opt.shiftwidth = 0 -- Number of spaces added for each indentation (0 = use 'tabstop')

-- Limits related to the line size
vim.opt.textwidth = 140
vim.opt.colorcolumn = '+1'

---Update the `vim.opt.listchars` settings.
---This option depends of the `tabstop` option. Every time the `tabstop` option is changed, the listchars option need to be updated. This
---function does the job. The user only need to run this function if changing the `tabstop` option. This can be done with a auto-command
---that triggers when the 'OptionSet' event is triggered.
---@param buffer_nr number Number of the buffer to update the `listchars` variable
---@param all_windows? boolean Apply to the global configuration if `true`. Apply to a local window if `false`
local function update_listchars(buffer_nr, all_windows)
	local indent_size = MYFUNC.get_indentation_size(buffer_nr)

	local window_opts = vim.opt

	if all_windows ~= true then
		local window_id = MYFUNC.get_window_by_buffer(buffer_nr)
		window_id = window_id >= 0 and window_id or 0
		window_opts = vim.wo[window_id]

		-- Only update the list chars if the indentation size changed
		if vim.w[window_id].__listchars_last_window_indent_size == indent_size then
			return
		end

		vim.w[window_id].__listchars_last_window_indent_size = indent_size
	end

	-- Data required to define the list chars

	local superscript_numbers = { '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹', '₀' } -- Indexes to be placed in the 'listchars' option

	local indent_size_is_even = math.fmod(indent_size, 2) == 0 -- If the indentation size is an even number
	local indent_size_half = math.floor(indent_size / 2) -- Half of the indentation size (integer, truncated)

	-- Spaces after any text
	local multispace_char = ''
	for _, index_char in ipairs(superscript_numbers) do
		multispace_char = multispace_char .. '𝅙⋅𝅙' .. index_char
	end

	-- Spaces before any text
	local lead_multispace_char = ''

	if indent_size > 2 then
		---Character to be placed between each indentation level
		---@type string
		local indent_separator_char = ''
		-- Alternative characters that you may want to use: 󰇝┆┃󱋱╎⎜┇¦╏┇┋┆┆┊󰇙⍿⟊¦‖⎸⋅⋯﴾﴿

		local spaces_before_index = string.rep('𝅙', indent_size_is_even and indent_size_half - 1 or indent_size_half)
		local spaces_after_index = string.rep('𝅙', indent_size_half - 1)

		-- Creates the components of the 'listchars' option that have index numbers
		for _, index_char in ipairs(superscript_numbers) do
			lead_multispace_char = lead_multispace_char .. spaces_before_index .. index_char .. spaces_after_index .. indent_separator_char
		end
	else
		local spaces_before_index = string.rep('𝅙', indent_size == 2 and 1 or 0)

		for _, index_char in ipairs(superscript_numbers) do
			lead_multispace_char = lead_multispace_char .. spaces_before_index .. index_char
		end
	end

	window_opts.listchars = 'tab:𝅙𝅙,leadmultispace:' .. lead_multispace_char .. ',multispace:' .. multispace_char
end

-- Initial 'listchars' setup
vim.opt.list = true
update_listchars(0, true)

-- Need to update the 'listchars' if any option related to the indentation size changes
vim.api.nvim_create_autocmd({ 'OptionSet', 'BufWinEnter' }, {
	callback = function(arguments)
		if MYFUNC.array_has({ 'tabstop', 'shiftwidth' }, arguments.match) then
			-- Does not changes the `listchars` option if the user can not change the window appearance
			if MYFUNC.user_can_change_appearance(nil, arguments.buf) then
				update_listchars(arguments.buf)
			end
		end
	end,
})

-- Need to update after a `BufWinEnter` to update the `listchars` option if the user opens more that one buffer in the command line. This
-- ensures that the buffer is attached to a window when updating the `listchars` option (this is a window option, so needs a window to be
-- applied).
vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
	callback = function(arguments)
		if MYFUNC.user_can_change_appearance(nil, arguments.buf) then
			update_listchars(arguments.buf)
		end
	end,
})

-- Custom characters
vim.opt.list = true
vim.opt.fillchars = 'foldopen:,foldclose:'

-- Other configurations
vim.opt.updatetime = 400
vim.opt.signcolumn = 'yes' -- Colunm with symbols used by other tools like LSP, Git, etc.
vim.opt.number = true -- Line number (if *relativenumber* is true, it is applied only to the current line)
vim.opt.relativenumber = true -- Relative line number (applied only to lines other than the current)
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.scrolloff = 6 -- Minimum number of lines before and after the cursor
