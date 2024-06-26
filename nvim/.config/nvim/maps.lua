-- You can see tips to mappings with ':h map-which-keys'
-- Keycodes can be found with this command ':h keycodes'
-- You can see if key is already mapped with ':verbose map <key>'


-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '  -- Recommended to be equal to mapleader (some plugins use this)
vim.g.secondleader = '_'    -- This is not a standard vim feature, but I will use in my mappings


-- My <S-F1>, <S-F2>, <S-F3> ... are equivalent to <F13>, <F14>, <F15> ...
-- My <C-F1>, <C-F2>, <C-F3> ... are equivalent to <F25>, <F26>, <F27> ...
-- My <S-C-F1>, <S-C-F2>, <S-C-F3> ... are equivalent to <F37>, <F38>, <F39> ...
-- My <A-F1>, <A-F2>, <A-F3> ... are equivalent to <F49>, <F50>, <F51> ...
-- My <S-A-F1>, <S-A-F2>, <S-A-F3> ... are equivalent to <F61>, <F62>, <F63> ...
-- My <C-A-F1>, <C-A-F2>, <S-A-F3> are used to switch between tty, so I can not map them.
-- The function bellow can be used to get the correct key code to these function keys

--- Get the correct key code from a Function key with a prefix (shift, alt, etc.)
-- @param prefix The prefix of the function key (e.g. 'S', 'C', 'S-C', 'A', 'S-A')
-- @param key_number The number of the function key
-- @return The function key equivalent to the prefix and the number
function myfunc.get_F_key(prefix, key_number)
	local prefix2number = {S = 12, C = 24, S_C = 36, A = 48, S_A = 60}

	return string.format('<F%d>', prefix2number[prefix] + key_number)
end



-- Functions to generate the option tables
local get_default_opt = myfunc.decorator_create_options_table({ noremap = true, silent = true })
local get_default_opt_no_silence = myfunc.decorator_create_options_table({ noremap = true, silent = false })


-- My documentation help
vim.keymap.set('n', '<F12>', '<CMD>:h mycfg.txt<CR>', get_default_opt('Open my documentation help'))

-- Navigation
vim.keymap.set('n', '<F1>', '<CMD>tabn<CR>', get_default_opt('Next tab'))
vim.keymap.set('n', myfunc.get_F_key('S', 1), '<CMD>tabp<CR>', get_default_opt('Previous tab'))
vim.keymap.set('n', '<BS>', '<CMD>execute "normal! <C-W><C-P>"<CR>', get_default_opt('Go to previous window'))
vim.keymap.set('n', '<C-u>', '<C-u>zz', get_default_opt('Scroll down the window and centralize'))
vim.keymap.set('n', '<C-d>', '<C-d>zz', get_default_opt('Scroll up the window and centralize'))

-- Search
vim.keymap.set('n', 'ch', '<CMD>nohlsearch<CR>', get_default_opt('Clear current search highlight'))

-- Find and replace
vim.keymap.set('n', '<A-f>', ':%s///g<left><left><left>', get_default_opt_no_silence('Replace in all file'))
vim.keymap.set('v', '<A-f>', ':s///g<left><left><left>', get_default_opt_no_silence('Replace only in selected text'))
vim.keymap.set('n', '<A-s>', ':%s/<C-r>///g<left><left>', get_default_opt_no_silence('Replace searched text in all file'))
vim.keymap.set('v', '<A-s>', ':s/<C-r>///g<left><left>', get_default_opt_no_silence('Replace searched text only in selected text'))
vim.keymap.set('v', '<A-r>', '""y:%s/<C-r>"//g<left><left>', get_default_opt_no_silence('Replace visual selected text in all file'))

-- Indentation
vim.keymap.set('v', '<S-TAB>', '<', get_default_opt('Indent current selection to left'))
vim.keymap.set('v', '<TAB>', '>', get_default_opt('Indent current selection to right'))
vim.keymap.set('n', '<S-TAB>', 'gv<', get_default_opt('Indent last selection to left'))
vim.keymap.set('n', '<TAB>', 'gv>', get_default_opt('Indent last selection to right'))

-- Select the last visual selection
vim.keymap.set('n', '<A-x>', 'gv', get_default_opt('Select last visual selection'))

-- Select all buffer
vim.keymap.set('n', 'vA', 'ggVG', get_default_opt('Select all buffer'))

-- Copy (e.g. Clipboard)
vim.keymap.set('v', '<A-c>', '"+y', get_default_opt('Copy current selection to clipboard'))
vim.keymap.set('n', '<A-c>', '<CMD>%y +<CR>', get_default_opt('Copy all buffer to clipboard'))
vim.keymap.set('n', 'yn', '<CMD>:let @"=\"\\n\"<CR>', get_default_opt('Copy newline to unnamed register'))

-- Change without saving the content to registers
vim.keymap.set({'n', 'v'}, vim.g.secondleader .. 'c', '"_c', get_default_opt('Change without saving to registers'))
vim.keymap.set({'n', 'v'}, vim.g.secondleader .. 'C', '"_C', get_default_opt('Change without saving to registers'))

-- Normal in other modes
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', get_default_opt('Normal mode into terminal'))  -- In terminal
vim.keymap.set({'n', 's'}, '<A-;>', ':<C-f>', get_default_opt('Open command-line window'))  -- The <C-f> need to be override if your 'cedit' is not 'CTRL-F'

-- Quickfix and Loclist
vim.keymap.set('n', '<F3>', '<CMD>lnext <CR>', get_default_opt('Go to next location list item'))
vim.keymap.set('n', myfunc.get_F_key('S', 3), '<CMD>lprev <CR>', get_default_opt('Go to previous location list item'))
vim.keymap.set('n', '<F4>', '<CMD>cnext <CR>', get_default_opt('Go to next quickfix list item'))
vim.keymap.set('n', myfunc.get_F_key('S', 4), '<CMD>cprev <CR>', get_default_opt('Go to previous quickfix list item'))

-- Movement with arrow keys in insert mode
vim.keymap.set('i', '<C-left>', '<CMD>normal! b<CR>', get_default_opt('Move cursor a word left'))
vim.keymap.set('i', '<C-right>', '<CMD>normal! w<CR>', get_default_opt('Move cursor a word right'))
vim.keymap.set('i', '<C-up>', '<CMD>normal! {<CR>', get_default_opt('Move cursor a paragraph back'))
vim.keymap.set('i', '<C-down>', '<CMD>normal! }<CR>', get_default_opt('Move cursor a paragraph forward'))

-- Fast repeat the macro saved in the 'q' register
vim.keymap.set({'n', 'v'}, ',', '@q', get_default_opt('Repeat macro "q"'))
vim.keymap.set('n', '<leader>,', ':let @q=@', get_default_opt('Copy a register content to "q" register'))

-- Backspace deletion maps (need to use <C-H> instead of <C-BS>)
vim.keymap.set('n', '<C-H>', 'dBx', get_default_opt('Delete a WORD back'))
vim.keymap.set('i', '<C-H>', '<CMD>normal! db<CR><right>', get_default_opt('Delete a word back'))

--- Only executes a deletion command if the cursor is not in the last column.
-- Also moves the cursor after the deletion if required to be more intuitive
-- @param delete_command The deletion command to be executed in command mode
-- @return The function that executes the deletion
local function decorator_delete_next_word(delete_command)
	return function()
		-- Does nothing if in the last column
		if vim.fn.col('.') == vim.fn.col('$') then
			return
		end

		-- Does the delete
		vim.cmd(delete_command)

		-- If the cursor goes to the last column after the delete, it will return to insert mode in a column before the current. To fix that
		-- I add 1 to the column number when it stops in the column before the last
		if vim.fn.col('.') == vim.fn.col('$')-1 then
			local cursor_pos = vim.api.nvim_win_get_cursor(0)  -- Line starts with 1, column starts with 0
			vim.api.nvim_win_set_cursor(0, { cursor_pos[1], cursor_pos[2] + 1 })
		end
	end
end

-- Del key mappings
vim.keymap.set('n', '<C-DEL>', decorator_delete_next_word('normal! dW'), get_default_opt('Delete a WORD next'))
vim.keymap.set('i', '<C-DEL>', decorator_delete_next_word('normal! dw'), get_default_opt('Delete a word next'))
