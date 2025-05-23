-- You can see tips to mappings with ':h map-which-keys'
-- Keycodes can be found with this command ':h keycodes'
-- You can see if key is already mapped with ':verbose map <key>'

-- Functions {{{

local simplified_keyword = '48-57,a-z,A-Z,192-255'

---Run a normal command in a environment that a keyword is defined by alphanumeric characters.
---@param callback string|function Normal command to execute.
local function run_with_simplified_keyword(callback)
	local iskeyword_bkp = vim.bo.iskeyword
	vim.bo.iskeyword = simplified_keyword

	local callback_type = type(callback)
	if callback_type == 'string' then
		vim.cmd.normal({
			args = { callback },
			bang = true,
		})
	elseif callback_type == 'function' then
		callback()
	end

	vim.bo.iskeyword = iskeyword_bkp
end

-- }}}

-- Leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- Recommended to be equal to mapleader (some plugins use this)
vim.g.secondleader = '_' -- This is not a standard vim feature, but I will use in my mappings

-- My <S-F1>, <S-F2>, <S-F3> ... are equivalent to <F13>, <F14>, <F15> ...
-- My <C-F1>, <C-F2>, <C-F3> ... are equivalent to <F25>, <F26>, <F27> ...
-- My <S-C-F1>, <S-C-F2>, <S-C-F3> ... are equivalent to <F37>, <F38>, <F39> ...
-- My <A-F1>, <A-F2>, <A-F3> ... are equivalent to <F49>, <F50>, <F51> ...
-- My <S-A-F1>, <S-A-F2>, <S-A-F3> ... are equivalent to <F61>, <F62>, <F63> ...
-- My <C-A-F1>, <C-A-F2>, <S-A-F3> are used to switch between tty, so I can not map them.
-- The function bellow can be used to get the correct key code to these function keys

--- Get the correct key code from a Function key with a prefix (shift, alt, etc.).
--- Depends on the user terminal emulator and keyboard. You should avoid complex key codes that may not be correctly interpret by Neovim
---@param prefix string The prefix of the function key (e.g. 'S', 'C', 'S-C', 'A', 'S-A')
---@param key_number number The number of the function key
---@return string function_key The function key equivalent to the prefix and the number
function MYFUNC.get_F_key(prefix, key_number)
	local prefix2number = { S = 12, C = 24, S_C = 36, A = 48, S_A = 60 }

	return string.format('<F%d>', prefix2number[prefix] + key_number)
end

local opts = {
	remap = true, -- Required
	silent = true,
}

-- Fix shift function key codes
for fkey_index = 1, 12 do
	local effective_keycode = fkey_index + 12
	local effective_map = '<F' .. effective_keycode .. '>'
	local desired_map = '<S-F' .. fkey_index .. '>'

	vim.keymap.set({ 'n', 'v', 'i' }, effective_map, desired_map, opts)
end

-- Functions to generate the option tables
local get_default_opt = MYFUNC.decorator_create_options_table({ remap = false, silent = true })
local get_default_opt_no_silence = MYFUNC.decorator_create_options_table({ remap = false, silent = false })
local get_default_opt_expr_no_silence = MYFUNC.decorator_create_options_table({ remap = false, expr = true, silent = false })

-- My documentation help
vim.keymap.set('n', '<F12>', '<CMD>:h mycfg.txt<CR>', get_default_opt('Open my documentation help'))

-- Navigation
vim.keymap.set('n', '<BS>', '<CMD>execute "normal! <C-W><C-P>"<CR>', get_default_opt('Go to previous window'))
vim.keymap.set('n', '<A-u>', '<C-u>zz', get_default_opt('Scroll down the window and centralize'))
vim.keymap.set('n', '<A-d>', '<C-d>zz', get_default_opt('Scroll up the window and centralize'))

---@alias key_direction
---| 'h' # left
---| 'j' # down
---| 'k' # up
---| 'l' # right

---Create a key map to move the focus to another window
---@param direction key_direction
---@param keys string[] List of keys to map
---@param description string Description of the created key map
local function create_move_keymap(direction, keys, description)
	local right_term_of_keymap = '<C-w>' .. direction
	local option_table = get_default_opt(description)
	for _, key in ipairs(keys) do
		vim.keymap.set('n', '<A-' .. key .. '>', right_term_of_keymap, option_table)
	end
end

create_move_keymap('h', { 'h', 'left' }, 'Move focus to the window left of the current one')
create_move_keymap('j', { 'j', 'down' }, 'Move focus to the window down of the current one')
create_move_keymap('k', { 'k', 'up' }, 'Move focus to the window up of the current one')
create_move_keymap('l', { 'l', 'right' }, 'Move focus to the window right of the current one')

-- Search
vim.keymap.set('n', 'ch', '<CMD>nohlsearch<CR>', get_default_opt('Clear current search highlight'))

-- Find and replace
vim.keymap.set('n', '<leader>ri', ':%s///g<left><left><left>', get_default_opt_no_silence('Replace input in all file'))
vim.keymap.set('v', '<leader>ri', ':s///g<left><left><left>', get_default_opt_no_silence('Replace input only in selected text'))
vim.keymap.set('n', '<leader>rs', ':%s/<C-r>///g<left><left>', get_default_opt_no_silence('Replace searched text in all file'))
vim.keymap.set('v', '<leader>rs', ':s/<C-r>///g<left><left>', get_default_opt_no_silence('Replace searched text only in selected text'))
vim.keymap.set('v', '<leader>rv', '""y:%s/<C-r>"//g<left><left>', get_default_opt_no_silence('Replace visual selected text in all file'))

local function get_search_item_without_escapes()
	local search = vim.fn.getreg('/')

	if search:sub(0, 2) == '\\V' then
		search = search:sub(3)
	end

	if search:sub(0, 2) == '\\<' then
		local search_size = #search
		search = search:sub(3, search_size - 2)
	end

	return search
end

vim.keymap.set('n', '<leader>res', function()
	return ':%s/<C-r>//' .. get_search_item_without_escapes() .. '/g<left><left>'
end, get_default_opt_expr_no_silence('Replace searched text by its edited content (all file)'))

vim.keymap.set('v', '<leader>res', function()
	return ':s/<C-r>//' .. get_search_item_without_escapes() .. '/g<left><left>'
end, get_default_opt_expr_no_silence('Replace searched text by its edited content (selected text)'))

vim.keymap.set(
	'v',
	'<leader>rev',
	'""y:%s/<C-r>"/<C-r>"/g<left><left>',
	get_default_opt_no_silence('Replace visual selected text by its edited content (all file)')
)

-- Indentation
vim.keymap.set('v', '<S-TAB>', '<gv', get_default_opt('Indent current selection to left'))
vim.keymap.set('v', '<TAB>', '>gv', get_default_opt('Indent current selection to right'))

-- Select the last visual selection
vim.keymap.set('n', '<A-x>', 'gv', get_default_opt('Select last visual selection'))

-- Select all buffer
vim.keymap.set('n', 'vA', 'ggVG', get_default_opt('Select all buffer'))

-- Copy (e.g. Clipboard)
vim.keymap.set('v', '<A-c>', '"+y', get_default_opt('Copy current selection to clipboard'))
vim.keymap.set('n', '<A-c>', '<CMD>%y +<CR>', get_default_opt('Copy all buffer to clipboard'))
vim.keymap.set('n', 'yn', '<CMD>:let @"="\\n"<CR>', get_default_opt('Copy newline to unnamed register'))

-- Change without saving the content to registers
vim.keymap.set({ 'n', 'v' }, vim.g.secondleader .. 'c', '"_c', get_default_opt('Change without saving to registers'))
vim.keymap.set({ 'n', 'v' }, vim.g.secondleader .. 'C', '"_C', get_default_opt('Change without saving to registers'))

-- Normal in other modes
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', get_default_opt('Normal mode into terminal')) -- In terminal
vim.keymap.set({ 'n', 's' }, '<A-;>', ':<C-f>', get_default_opt('Open command-line window')) -- The <C-f> need to be override if your 'cedit' is not 'CTRL-F'

-- Movement with arrow keys in insert mode
vim.keymap.set('i', '<C-left>', '<CMD>normal! b<CR>', get_default_opt('Move cursor a word left'))
vim.keymap.set('i', '<C-right>', '<CMD>normal! w<CR>', get_default_opt('Move cursor a word right'))
vim.keymap.set('i', '<C-up>', '<CMD>normal! {<CR>', get_default_opt('Move cursor a paragraph back'))
vim.keymap.set('i', '<C-down>', '<CMD>normal! }<CR>', get_default_opt('Move cursor a paragraph forward'))

vim.keymap.set('i', '<A-left>', function()
	run_with_simplified_keyword('b')
end, get_default_opt('Move cursor a simplified word left'))

vim.keymap.set('i', '<A-right>', function()
	run_with_simplified_keyword('w')
end, get_default_opt('Move cursor a simplified word right'))

vim.keymap.set('i', '<A-up>', '<CMD>normal! k<CR>', get_default_opt('Move cursor up'))
vim.keymap.set('i', '<A-down>', '<CMD>normal! j<CR>', get_default_opt('Move cursor down'))

-- Go to next/previous word

vim.keymap.set({ 'n', 'v', 'i' }, '<A-w>', function()
	run_with_simplified_keyword('w')
end, get_default_opt('Forward to a simplified word'))

vim.keymap.set({ 'n', 'v', 'i' }, '<A-e>', function()
	run_with_simplified_keyword('e')
end, get_default_opt('Forward to the end of a simplified word'))

vim.keymap.set({ 'n', 'v', 'i' }, '<A-b>', function()
	run_with_simplified_keyword('b')
end, get_default_opt('Backward to a simplified word'))

-- Fast repeat the macro saved in the 'q' register
vim.keymap.set({ 'n', 'v' }, '<A-.>', '@q', get_default_opt('Repeat macro "q"'))
vim.keymap.set('n', '<leader>.', ':let @q=@', get_default_opt('Copy a register content to "q" register'))

-- Backspace deletion. Some terminal emulators does not have a <C-BS> key. They use <C-w> or <C-h> instead
vim.keymap.set('i', '<C-w>', '<C-BS>', { remap = true, silent = true, desc = 'Same as the <C-BS> key' })
vim.keymap.set('i', '<C-h>', '<C-BS>', { remap = true, silent = true, desc = 'Same as the <C-BS> key' })

-- Delete the previous word. Like the <C-BS> key bind on others IDEs.
local function delete_previous_word()
	local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Line (starts with 1) | column (starts with 0)
	local last_col = vim.fn.col('$') - 1 -- Max column that the cursor can go in insert mode

	-- Does nothing if in the first column, so the user will not accidentally delete the previous line. Release CTRL and press BACKSPACE if
	-- you want to continue the deletion
	if cursor_pos[2] == 0 then
		return
	end

	-- Deletion
	vim.cmd.normal({ 'db', bang = true })

	-- The delete operation is performed with a normal command. If the cursor is in the last column, the delete operation places the cursor
	-- one column before the last (moves one column to the left). To fix this, we need to manually move the cursor to the right. I tried
	-- using a normal command to do this, but it didn't work
	if cursor_pos[2] == last_col then
		cursor_pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_win_set_cursor(0, { cursor_pos[1], cursor_pos[2] + 1 })
	end
end

vim.keymap.set('i', '<C-BS>', delete_previous_word, get_default_opt('Delete the previous word'))

vim.keymap.set('i', '<A-BS>', function()
	run_with_simplified_keyword(delete_previous_word)
end, get_default_opt('Delete the previous simplified word'))

-- Delete the next word. Like the <C-Del> key bind on others IDEs.
local function delete_next_word()
	local cursor_pos = vim.api.nvim_win_get_cursor(0) -- Line (starts with 1) | column (starts with 0)
	local last_col = vim.fn.col('$') - 1 -- Max column that the cursor can go in insert mode

	-- Does nothing if in the last column, so the user will not accidentally delete the next line. Release CTRL and press backspace if you
	-- want to continue the deletion
	if cursor_pos[2] == last_col then
		return
	end

	-- Delete operation. This operation can move the cursor to a another position. This is not the desired behavior. So need to restore the
	-- cursor position to the one before the delete operation
	vim.cmd.normal({ 'dw', bang = true })
	vim.api.nvim_win_set_cursor(0, cursor_pos)
end

-- Del the next word with <C-DEL>
vim.keymap.set('i', '<C-DEL>', delete_next_word, get_default_opt('Delete the next word'))

vim.keymap.set('i', '<A-DEL>', function()
	run_with_simplified_keyword(delete_next_word)
end, get_default_opt('Delete the next simplified word'))
