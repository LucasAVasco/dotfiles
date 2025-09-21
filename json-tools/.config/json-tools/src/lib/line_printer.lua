local M = {}

---@class lib.line_printer.LineInterval
---@field start integer Starting index of the line to print.
---@field stop integer Stop showing at this line

---@class lib.line_printer.LinePrinter
---@field _line_intervals lib.line_printer.LineInterval[]
---@field _current_line integer
---@field _last_lines string[]
---@field _max_num_last_lines integer
M.LinePrinter = {}
M.LinePrinter.__index = M.LinePrinter

function M.LinePrinter:new()
	---@type lib.line_printer.LinePrinter
	local line_printer = {
		_line_intervals = {},
		_current_line = 0,
		_last_lines = {},
		_max_num_last_lines = 0,
	}

	setmetatable(line_printer, M.LinePrinter)
	return line_printer
end

---Fix the order of the interval.
---@param interval lib.line_printer.LineInterval
function M.LinePrinter:_fix_interval_order(interval)
	local start = interval.start
	local stop = interval.stop

	if start < stop then
		return
	end

	-- Does nothing with intervals that `start` and `stop` have the same signal.
	if (start < 0 and stop > 0) or (start > 0 and stop < 0) then
		return
	end

	interval.start, interval.stop = interval.stop, interval.start
end

---Add a line interval.
---@param start integer
---@param stop integer
--- INFO(LucasAVasco): You must add all intervals before calling `handle_line` method.
function M.LinePrinter:add_line_interval(start, stop)
	---@type lib.line_printer.LineInterval
	local config = {
		start = start,
		stop = stop,
	}

	-- Updates the maximum buffer size
	local new_size = start < stop and start or stop
	if new_size < 0 then
		self:_update_max_buffer_size(-new_size)
	end

	self:_fix_interval_order(config)

	table.insert(self._line_intervals, config)
end

-- Internal buffer functions {{{

---Update the max buffer size.
---@param size integer New size, in number of lines. If the size is smaller than the current size, nothing happens.
--- INFO(LucasAVasco): do not call this function after inserting (`handle_line` method)any line.
function M.LinePrinter:_update_max_buffer_size(size)
	if size > self._max_num_last_lines then
		self._max_num_last_lines = size
	end
end

---Add a line to the buffer.
---@param line string
---@return string?
function M.LinePrinter:_add_line_to_buffer(line)
	table.insert(self._last_lines, line)

	if #self._last_lines > self._max_num_last_lines then
		return table.remove(self._last_lines, 1)
	end
end

-- }}}

---Checks if a line number is in a interval.
---intervals with negative range (example: start = -3 and stop = -1) are calculated relative to the current line.
---@param line integer Line number to check.
---@param interval lib.line_printer.LineInterval Interval to check.
---@return boolean
function M.LinePrinter:_line_is_in_interval(line, interval)
	local start = interval.start
	if start < 0 then
		start = start + self._current_line + 1
	end

	local stop = interval.stop
	if stop < 0 then
		stop = stop + self._current_line + 1
	end

	return line >= start and line <= stop
end

---Prints the lines that are in any configured interval.
---This method can not print all lines, because some intervals may refer to a negative index (relative to the end). In complement to this
---method, the missing lines are printed in the `print_missing_lines()` method.
---@param line string
function M.LinePrinter:handle_line(line)
	-- Current line number
	self._current_line = self._current_line + 1

	-- Line drooped from the buffer
	local buffer_line = self:_add_line_to_buffer(line)

	-- Prints the line if it is in any interval that starts in a positive index
	if buffer_line then
		local line_num = self._current_line - #self._last_lines

		for _, interval in ipairs(self._line_intervals) do
			-- Can not that starts in a negative index until all lines are received
			if interval.start > 0 and self:_line_is_in_interval(line_num, interval) then
				print(buffer_line)
				break
			end
		end
	end
end

---Print all non-printed lines if them are in the intervals.
---Print lines that can not be printed until the end of the file (example: line ranges with negative index).
function M.LinePrinter:print_missing_lines()
	local buffer_size = #self._last_lines

	for i, line in ipairs(self._last_lines) do
		i = self._current_line + i - buffer_size

		for _, interval in ipairs(self._line_intervals) do
			if self:_line_is_in_interval(i, interval) then
				print(line)
				break
			end
		end
	end
end

return M
