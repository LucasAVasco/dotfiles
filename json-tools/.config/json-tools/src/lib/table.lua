local text = require("lib.text")
local colors = require("lib.colors")

local table_line_color = colors.fg.blue
local table_row_number_color = colors.fg.blue
local table_column_color = colors.fg.green

local M = {}

---@class format_table.row
---@field index integer
---@field value table<string, string>

---@class format_table.Table
---@field _col_size table<string, integer> Relates all columns to its size (size of the bigger column).
---@field _col_number integer
---@field _rows format_table.row[]
---@field _buffer_size integer Recommended max number of rows of the table.
---@field _current_col_index integer
---@field _col_order string[]
M.Table = {}
M.Table.__index = M.Table

---Create a new table object.
---@param buffer_size integer
---@return format_table.Table
function M.Table:new(buffer_size)
	---@type format_table.Table
	local new_table = {
		_col_size = {},
		_col_number = 0,
		_rows = {},
		_buffer_size = buffer_size,
		_current_col_index = 1,
		_col_order = {},
	}

	setmetatable(new_table, self)

	return new_table
end

---Iterate over a Lua table columns.
---@param t table
---@param prefix string
---@param func fun(col: string, value: any)
local function iter_table_columns(t, prefix, func)
	for col, value in pairs(t) do
		if type(value) == "table" then
			iter_table_columns(value, prefix .. col .. ".", func)
		else
			value = tostring(value)
			func(prefix .. col, value)
		end
	end
end

---Insert a JSON object as a row.
---@param row table<string, any>
function M.Table:insert_row(row)
	-- New row to add to the table
	local row_value = {}

	---@type format_table.row
	local new_row = {
		index = self._current_col_index,
		value = row_value,
	}

	self._current_col_index = self._current_col_index + 1

	-- Extracts the columns
	iter_table_columns(row, "", function(col, value)
		value = tostring(value)
		value = text.escape(value)

		col = text.escape(col)

		local col_size = self._col_size[col]

		-- Initial value
		if col_size == nil then
			col_size = #col
			self._col_size[col] = col_size

			self._col_number = self._col_number + 1
		end

		-- Updates the size
		if #value > col_size then
			self._col_size[col] = #value
		end

		-- Adds the value
		row_value[col] = value
	end)

	-- Adds the row to its list
	table.insert(self._rows, new_row)
end

---Get the number of non-printed rows.
---@return integer
function M.Table:num_rows()
	return #self._rows
end

---Update the column order.
function M.Table:_update_col_order()
	self._col_order = {}

	-- Add columns to the order
	for col, _ in pairs(self._col_size) do
		table.insert(self._col_order, col)
	end

	-- Sort the columns
	table.sort(self._col_order, function(a, b)
		return a < b
	end)
end

---Iterate over the sorted columns of the table.
---@param func fun(name: string, size: integer, index: integer)
function M.Table:_iter_columns(func)
	for i, col in pairs(self._col_order) do
		func(col, i, self._col_size[col])
	end
end

-- Methods to print the table content {{{

---Print a string.
---@param str string
function M.Table:_write(str)
	io.write(str)
end

---Set the current color of the output text.
---@param color string Color space code.
function M.Table:_set_color(color)
	self:_write(color)
end

---Print a lines. Example: vertical lines, horizontal lines, etc.
---Use the default color for lines.
---@param str string Line content.
function M.Table:_write_line(str)
	self:_set_color(table_line_color)
	self:_write(str)
	self:_set_color(colors.fg.reset)
end

---Print a row number.
---Use the default color for row numbers.
---@param str string Row number.
function M.Table:_write_row_number(str)
	self:_set_color(table_row_number_color)
	self:_write(str)
	self:_set_color(colors.fg.reset)
end

---Print a horizontal line of a given character.
---Use the default color for lines.
---@param char string Character to print.
---@param size integer Number of times to print the char.
function M.Table:_print_horizontal_line(char, size)
	self:_set_color(table_line_color)

	for _ = 1, size do
		self:_write(char)
	end

	self:_set_color(colors.fg.reset)
end

---Print spaces.
---@param size integer Number of spaces to print.
function M.Table:_print_horizontal_spaces(size)
	for _ = 1, size do
		self:_write(" ")
	end
end

---Print a column name.
---Use the default color for column names.
---@param name string Column name.
function M.Table:_write_column_name(name)
	self:_set_color(table_column_color)
	self:_write(name)
	self:_set_color(colors.fg.reset)
end

---Return the size of the row number column.
---@return integer
function M.Table:_get_row_number_str_size()
	local num = utf8.len(tostring(self._current_col_index))
	return num or 1
end

---Print the table headers.
function M.Table:_print_headers()
	-- Top Line (row number)
	self:_write_line("┌")
	self:_print_horizontal_line("─", self:_get_row_number_str_size() + 2)
	self:_write_line("┬")

	-- Top line (column headers)

	self:_iter_columns(function(_, i, size)
		self:_print_horizontal_line("─", size + 2)

		if i < #self._col_order then
			self:_write_line("┬")
		end
	end)

	self:_write_line("┐\n")

	-- Column headers
	self:_write_line("│ ")
	self:_print_horizontal_spaces(self:_get_row_number_str_size() + 1)

	self:_iter_columns(function(name, _, size)
		local num_spaces = size - utf8.len(name) + 1

		self:_write_line("│ ")

		-- Number of spaces at the left of the column
		local left_spaces = math.ceil(num_spaces / 2) - 1
		self:_print_horizontal_spaces(left_spaces)

		-- Column name
		self:_write_column_name(name)

		-- Number of spaces at the right of the column
		self:_print_horizontal_spaces(num_spaces - left_spaces)
	end)

	-- Shows the missing vertical line if there is no column
	if #self._col_order == 0 then
		self:_write_line("│")
	end

	self:_write_line("│\n")

	-- Bottom Line (row number)
	self:_write_line("├")
	self:_print_horizontal_line("─", self:_get_row_number_str_size() + 2)
	self:_write_line("┼")

	-- Bottom line (column headers)
	self:_iter_columns(function(_, i, size)
		self:_print_horizontal_line("─", size + 2)
		if i < #self._col_order then
			self:_write_line("┼")
		end
	end)

	self:_write_line("┤\n")
end

---Print a table row.
---@param row format_table.row
function M.Table:_print_line(row)
	-- Prints the row index
	self:_write_line("│ ")
	self:_write_row_number(tostring(row.index))
	self:_print_horizontal_spaces(self:_get_row_number_str_size() - utf8.len(tostring(row.index)) + 1)

	-- Prints the row content
	self:_iter_columns(function(name)
		local value = row.value[name]

		self:_write_line("│ ")
		self:_write(value)
		self:_print_horizontal_spaces(self._col_size[name] - utf8.len(value) + 1)
	end)

	-- Shows the missing vertical line if there is no column
	if #self._col_order == 0 then
		self:_write_line("│")
	end

	self:_write_line("│\n")
end

---Print all table rows.
function M.Table:_print_all_lines()
	for _, row in pairs(self._rows) do
		self:_print_line(row)
	end
end

---Print the table bottom.
function M.Table:_print_bottom()
	-- Row number indicator
	self:_write_line("└")
	self:_print_horizontal_line("─", self:_get_row_number_str_size() + 2)
	self:_write_line("┴")

	-- Columns

	self:_iter_columns(function(_, i, size)
		self:_print_horizontal_line("─", size + 2)
		if i < #self._col_order then
			self:_write_line("┴")
		end
	end)

	self:_write_line("┘\n")
end

---Print the table.
function M.Table:print()
	self:_update_col_order()

	-- Printing
	self:_print_headers()
	self:_print_all_lines()
	self:_print_bottom()
end

---Clear all rows.
function M.Table:clear()
	self._rows = {}
	self._col_size = {}
	self._col_number = 0
	self._col_order = {}
end

---Print the table and clear it.
function M.Table:print_and_clear()
	self:print()
	self:clear()
end

---Print the table and clear it if the buffer is full.
function M.Table:print_full_buffer_and_clear()
	if #self._rows >= self._buffer_size then
		self:print_and_clear()
	end
end

-- }}}

return M
