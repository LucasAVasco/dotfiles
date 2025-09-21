local c_json = require("cjson")

local M = {}

---Read the standard input (structured as JSON) and send it to the handler.
---@param handler fun(input: table): string? Handler function. Returns an error message
---@return string? Error
function M.handle_input(handler)
	for line in io.lines() do
		---@type table
		local input = c_json.decode(line)

		local err = handler(input)
		if err then
			return "error handling input: " .. err
		end
	end
end

---Write the data to the standard output.
---@param json table Data to write
function M.write_table_output(json)
	io.write(c_json.encode(json))
	io.write("\n")
end

---Write the data to the standard output.
---@param json string Data to write
function M.write_encoded_output(json)
	io.write(json)
	io.write("\n")
end

return M
