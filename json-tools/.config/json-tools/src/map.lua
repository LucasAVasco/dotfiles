require("lib.help").handle_help_message([[
Map each row of the input table to a new row. Outputs a new table with these new rows.

USAGE
map [-h | --help]
	Show this help message.

map <map-expression>
	Create a new row with the result of the given map expression and replaces the old row.

MAP EXPRESSION
	The expression is a Lua code that must results in a table. Example: `{name = "John", age = 30}`.
	You can access the fields of the source (input) row by the `i` table. Example: `{name = i.name, age = i.age}`.
]])

local parser = require("lib.json_parser")
local expression = require("lib.expression")

---@return string?
local function main()
	local map_expression = table.concat(arg)

	-- Map function
	local map_function, err = expression.compile_function({ "i" }, "return " .. map_expression)

	if err then
		return "error compiling map expression function: " .. err
	end

	-- Runs the filter

	err = parser.handle_input(function(input)
		parser.write_table_output(map_function(input))
	end)

	if err then
		return "error handling input: " .. err
	end
end

local err = main()
if err then
	print(err)
end
