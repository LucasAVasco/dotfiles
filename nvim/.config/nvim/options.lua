-- Files configurations
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding ='utf-8'

-- Backup, undo and swap files
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.swapfile = true

local home_path = vim.env.HOME

vim.fn.system({'mkdir', '-p', home_path .. '/.nvim/.backup_files/', home_path .. '/.nvim/.undo_files/', home_path .. '/.nvim/.swap_files/'})
vim.opt.backupdir = home_path .. '/.nvim/.backup_files//'
vim.opt.undodir = home_path .. '/.nvim/.undo_files//'
vim.opt.directory = home_path .. '/.nvim/.swap_files//'

-- Mouse configurations
vim.opt.hidden = true
vim.opt.mouse = 'a'

-- Load the plugin files for specific file types
vim.cmd('filetype plugin on')

-- Load the indent file for specific file types
vim.cmd("filetype indent on")

-- Indentation
vim.opt.expandtab = false  -- Expand tabs to spaces convert tabs to spaces
vim.opt.smarttab = false   -- The smarttab option change how to use the 'tabstop', 'softtabstop' and 'shiftwidth'options
vim.opt.tabstop = 4        -- Number of spaces that a Tab represents
vim.opt.softtabstop = -1   -- Number of spaces added for Tab when editing ( <0 = use 'shiftwidth')
vim.opt.shiftwidth = 0     -- Number of spaces added for each indentation (0 = use 'tabstop')

-- Limits related to the line size
vim.opt.textwidth = 140
vim.opt.colorcolumn = '+1'

--- Update the `vim.opt.listchars` settings
-- This option depends of the `tabstop` option. Every time the `tabstop` option is changed, the listchars option need to be updated
-- This function does the job. The user only need to run this function if changing the `tabstop` option. This can be done with a
-- auto-command that triggers when the 'OptionSet' event is triggered
local function update_listchars()
	local superscript_numbers = {'¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'}  -- Indexes to be placed in the 'listchars' option

	local indent_size = vim.opt.tabstop:get()             -- Number of spaces of a indentation level
	local indent_even = math.fmod(indent_size, 2) == 0    -- If the indentation size is an even number
	local indent_size_half = math.floor(indent_size / 2)  -- Half of the indentation size (integer, truncated)

	-- Number of times to repeat the space character at the left of the index number (used by *lead_multispace_char*)
	local n_repeat_left = indent_even and indent_size_half - 1 or indent_size_half

	-- Spaces before any text (first identation level)
	local lead_multispace_char = string.rep('𝅙', n_repeat_left) .. '⁰' .. string.rep('𝅙', indent_size_half - 1) .. '┋'

	-- Spaces after any text (first 4 characters)
	local multispace_char = '𝅙⋅𝅙₀'

	-- Creates the components of the 'listchars' option that have index numbers
	for _, index_char in ipairs(superscript_numbers) do
		lead_multispace_char = lead_multispace_char .. string.rep('𝅙', n_repeat_left) .. index_char .. string.rep('𝅙', indent_size_half - 1) .. '┋'

		multispace_char = multispace_char .. '𝅙⋅𝅙' .. index_char
	end

	vim.opt.listchars = 'tab:𝅙𝅙┋,leadmultispace:' .. lead_multispace_char .. ',multispace:' .. multispace_char
	-- Alternative characters -> 󰇝┆┃󱋱╎⎜┇¦╏┇┋⸽┆┆┊󰇙⦚⸽⍿⟊⫯⫰¦‖⸾⸾⎸⋅⋯﴾﴿
end

-- Initial 'listchars' setup
vim.opt.list = true
update_listchars()

-- Update the 'listchars' option when the 'tabstop' option is changed. As described in the `update_listchars()` function, this is
-- done because the listchars option depends of the 'tabstop' option
vim.api.nvim_create_autocmd({'OptionSet'}, {
	group = indent_augroupe, callback = function(arguments)
		if arguments.match == 'tabstop' then
			-- Does not apply the settings if the user ca
			if myfunc.user_can_change_appearance(nil, arguments.buf) then
				update_listchars()
			end
		end
	end
})

-- Custom characters
vim.opt.list = true
vim.opt.fillchars = 'foldopen:,foldclose:'

-- Other configurations
vim.opt.updatetime = 400
vim.opt.signcolumn = "yes"     -- Colunm with symbols used by other tools like LSP, Git, etc.
vim.opt.number = true          -- Line number (if *relativenumber* is true, it is applied only to the current line)
vim.opt.relativenumber = true  -- Relative line number (applied only to lines other than the current)
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.scrolloff = 6          -- Minimum number of lines before and after the cursor
