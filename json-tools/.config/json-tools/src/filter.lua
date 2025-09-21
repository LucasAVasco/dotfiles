require("lib.help").handle_help_message([[
Filter the input rows.

USAGE
filter [-h | --help]
	Show this help message.

filter <filter-expression>
	Prints the rows that matches the given filter expression.

FILTER EXPRESSION
	The expression is a Lua code that must results in a boolean. Example: `i.name == "John"`.
	You can access the row fields by the `i` table.
]])

local parser = require("lib.json_parser")
local expression = require("lib.expression")

---@return string?
local function main()
	local filter_expression = table.concat(arg)

	-- Filter function
	local filter_function, err = expression.compile_function({ "i" }, "return " .. filter_expression)

	if err then
		return "error compiling filter expression function: " .. err
	end

	-- Runs the filter

	err = parser.handle_input(function(input)
		if filter_function(input) then
			parser.write_table_output(input)
		end
	end)

	if err then
		return "error handling input: " .. err
	end
end

local err = main()
if err then
	print(err)
end
