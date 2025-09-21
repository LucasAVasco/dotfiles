require("lib.help").handle_help_message([[
Print a sub-set of the input rows.

USAGE
rows [-h | --help]
	Show this help message.

rows <row-patterns...>
	Print only the rows that match the given patterns.

LINES PATTERN
	<start>,<stop>
		Print the rows from <start> to <stop> (inclusive).
	<start>
		Print the <start> row.

	Supports the following signals:
	<row-num> Absolute number of the row (starts in 1).
	- <row-num> Negative index, relative to the last row.

	The <stop> row also support the following signals:
	+ <row-num> Number of the row relative to <start-row> (starts in 1).
]])

local line_printer = require("lib.line_printer")

---Parse a row pattern received from the command line.
---@param pattern string Pattern to parse
---@return lib.line_printer.LineInterval configuration, string? error
local function parse_row_pattern(pattern)
	local start_signal, start, stop_signal, stop = pattern:match("(%p?)([0-9]+),(%p?)([0-9]+)")
	if not stop then
		start_signal, start = pattern:match("(%p?)([0-9]+)") -- Pattern without stop (implicit `stop = start`)
		stop_signal = start_signal
		stop = start
	end

	if not start then
		return {}, "invalid row pattern: " .. pattern
	end

	-- Handles the signal of the start line
	if start_signal and start_signal == "-" then
		start = -start
	end

	-- Handles the signal of the stop line
	if stop_signal then
		if stop_signal == "-" then
			stop = -stop
		elseif stop_signal == "+" then
			stop = stop + start
		end
	end

	return {
		start = tonumber(start),
		stop = tonumber(stop),
	}
end

---@return string?
local function main()
	local printer = line_printer.LinePrinter:new()

	for _, print_arg in ipairs(arg) do
		local line_to_print, err = parse_row_pattern(print_arg)
		if err then
			return "error parsing row pattern: " .. err
		end

		printer:add_line_interval(line_to_print.start, line_to_print.stop)
	end

	-- Handles all lines

	for line in io.lines() do
		printer:handle_line(line)
	end

	printer:print_missing_lines()
end

local err = main()
if err then
	print(err)
end
