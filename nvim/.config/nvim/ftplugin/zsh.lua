local Terminal = require('toggleterm.terminal').Terminal

--- Get the current buffer content (all lines) as a string
---@return string
local get_current_buffer_lines_as_string = function()
	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
end

--- Execute the current file as a script in a new terminal. Uses the terminal shell
local function execute_current_file()
	Terminal:new({
		cmd = get_current_buffer_lines_as_string(),
		hidden = true,
		display_name = 'Execute current file',
		close_on_exit = false,
	}):open()
end

-- Key map to execute the current file in a new terminal
if vim.env.EDITING_COMMAND_LINE == 'y' then
	vim.keymap.set('n', '<CR>', execute_current_file, {
		buffer = true,
		silent = true,
		desc = 'Execute current file in a new terminal. Press any button to close',
	})
end
