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
	local indent_size = vim.bo[buffer_nr].tabstop -- Number of spaces of a indentation level

	local window_opts = vim.wo

	if all_windows ~= nil then
		local window_id = MYFUNC.get_window_by_buffer(buffer_nr)
		window_id = window_id >= 0 and window_id or 0

		window_opts = window_opts[window_id]

		-- Only update the list chars if the `tabstop` option changed
		if vim.w[window_id].__last_window_indent_size == indent_size then
			return
		end

		vim.w[window_id].__last_window_indent_size = indent_size
	end

	-- Data required to define the list chars

	local superscript_numbers = { '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' } -- Indexes to be placed in the 'listchars' option

	local indent_even = math.fmod(indent_size, 2) == 0 -- If the indentation size is an even number
	local indent_size_half = math.floor(indent_size / 2) -- Half of the indentation size (integer, truncated)

	-- Repeat the space character at the left of the index number (used by *lead_multispace_char*).
	local spaces_before_index_num = string.rep('𝅙', indent_even and indent_size_half - 1 or indent_size_half)

	-- Repeat the space character at the right of the index number (used by *lead_multispace_char*).
	local spaces_after_index_num = string.rep('𝅙', indent_size_half - 1)

	-- First indentation level of the multi spaces characters

	local lead_multispace_char = spaces_before_index_num .. '⁰' .. spaces_after_index_num .. '󰇙' -- Spaces before any text
	local multispace_char = '𝅙⋅𝅙₀' -- Spaces after any text

	-- Creates the components of the 'listchars' option that have index numbers
	for _, index_char in ipairs(superscript_numbers) do
		lead_multispace_char = lead_multispace_char .. spaces_before_index_num .. index_char .. spaces_after_index_num .. ''
		multispace_char = multispace_char .. '𝅙⋅𝅙' .. index_char
	end

	window_opts.listchars = 'tab:𝅙𝅙,leadmultispace:' .. lead_multispace_char .. ',multispace:' .. multispace_char
	-- Alternative characters that you may want to use -> 󰇝┆┃󱋱╎⎜┇¦╏┇┋┆┆┊󰇙⍿⟊¦‖⎸⋅⋯﴾﴿
end

-- Initial 'listchars' setup
vim.opt.list = true
update_listchars(0, true)

-- Updates the `listchars` option when the `tabstop` option changes. As described in the `update_listchars()` function. Use this approach
-- because my custom `listchars` option depends on the `tabstop` option. Need to update after a `BufWinEnter` to update the `listchars`
-- option if the user opens more that one buffer in the command line. This ensures that the buffer is attached to a window when updating the
-- `listchars` option (this is a window option, so needs a window to be applied).
vim.api.nvim_create_autocmd({ 'OptionSet', 'BufWinEnter' }, {
	callback = function(arguments)
		if arguments.match == 'tabstop' or arguments.event == 'BufWinEnter' then
			-- Does not changes the `listchars` option if the user can not change the window appearance
			if MYFUNC.user_can_change_appearance(nil, arguments.buf) then
				update_listchars(arguments.buf)
			end
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
