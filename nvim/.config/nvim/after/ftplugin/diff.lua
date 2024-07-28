---Return the line content with the diff patch disabled
---@param line string
---@return string?
---@nodiscard
local function disable_line(line)
	local first_char = line:sub(1, 1)

	if first_char == '+' then
		return

	elseif first_char == '-' then
		return ' ' .. line:sub(2, #line)

	else
		return line
	end
end


---Disable the diff patch in a range of lines of the current buffer.
---Also disable the patch in the *start* and *end* lines.
---@param start_line number Zero based index of the start line of the range
---@param end_line number Zero based index of the end line of the range
local function disable_buffer_lines(start_line, end_line)
	local buffer_br = vim.api.nvim_get_current_buf()

	-- The `nvim_buf_get_lines()` and `nvim_buf_set_lines` functions does not includes the end line (different from the current function).
	-- To ensure the `end_line` will be include in the disable operation, need to change it to the next line
	end_line = end_line + 1

	-- Lines content
	local lines = vim.api.nvim_buf_get_lines(buffer_br, start_line, end_line, true)

	---@type string[]
	local disabled_lines = {}

	for _, line_to_disable in pairs(lines) do
		local disabled_line = disable_line(line_to_disable)

		if disabled_line then
			table.insert(disabled_lines, disabled_line)
		end
	end

	vim.api.nvim_buf_set_lines(buffer_br, start_line, end_line, true, disabled_lines)
end


---Disable the diff patch in the current line
local function disable_current_line()
	local line = vim.api.nvim_win_get_cursor(0)[1]  -- Line starts in 1

	disable_buffer_lines(line-1, line-1)
end


---Disable the diff patch in the visual selected lines
local function disable_visual_selected_lines()
	-- Exit visual mode. Required to access the marks with `vim.api.nvim_buf_get_mark`
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'x', false)

	-- Get positions of the last visual selected block with the '<' and '>' marks

	local start_line = vim.api.nvim_buf_get_mark(0, '<')[1]  -- Line starts in 1
	local end_line = vim.api.nvim_buf_get_mark(0, '>')[1]    -- Line starts in 1

	disable_buffer_lines(start_line - 1, end_line - 1)
end


-- Key maps to disable lines of diff patches

local get_opts = MYFUNC.decorator_create_options_table({
	buffer = vim.api.nvim_get_current_buf(),
	noremap = true,
	silent = true,
})

vim.keymap.set('n', 'dd', disable_current_line, get_opts('Disable the current line patch'))
vim.keymap.set('x', 'd', disable_visual_selected_lines, get_opts('Disable the current selected lines patches'))
