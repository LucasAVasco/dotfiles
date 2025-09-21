require("lib.help").handle_help_message([[
Converts the input (Json lines) as a pretty table.

USAGE
pretty [-h | --help]
	Show this help message.

pretty
	Convert the input (Json lines) to a pretty printed table. Example: `echo '{"name": "John", "age": 30}' | pretty`.
]])

local parser = require("lib.json_parser")
local lib_table = require("lib.table")

---@return string?
local function main()
	local t = lib_table.Table:new(100)

	local err = parser.handle_input(function(input)
		t:insert_row(input)
		t:print_full_buffer_and_clear()
	end)

	if err then
		return "error handling input: " .. err
	end

	if t:num_rows() > 0 then
		t:print_and_clear()
	end
end

local err = main()
if err then
	print(err)
end
