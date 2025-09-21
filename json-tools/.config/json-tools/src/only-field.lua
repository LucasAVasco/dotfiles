require("lib.help").handle_help_message([[
Copy only the given fields from the input. Delete all other fields.

USAGE
only-field [-h | --help]
	Show this help message.

only-field <field...>
	Delete all fields except the given fields from the input rows.
	You can specify sub-fields with a dot. Example: `top_field.sub_field.sub_sub_field`.
]])

local parser = require("lib.json_parser")
local text = require("lib.text")

---Copy a single field from a table (with recursive access).
---@param src table Copy the field from this object.
---@param dest table Copy the field to this object.
---@param field string[] Field to copy. e.g. ["top_field", "sub_field", "sub_sub_field"]
local function copy_field(src, dest, field)
	local value = src

	-- Gets the field value
	for _, sub_field in ipairs(field) do
		value = value[sub_field]
		if value == nil then
			return -- Field does not exist
		end
	end

	local last_obj = dest

	-- Traverses the object until the parent object of the last field
	for i = 1, #field - 1 do
		local sub_field = field[i]
		local sub_obj = last_obj[sub_field]

		-- Creates the object if it doesn't exist
		if sub_obj == nil then
			sub_obj = {}
			last_obj[sub_field] = sub_obj
		end

		-- Updates the object
		last_obj = sub_obj
	end

	-- Copies the value to the last field
	last_obj[field[#field]] = value
end

---@return string?
local function main()
	---@type string[][] List of fields to delete. Each field is a list of strings, e.g. ["top_field", "sub_field", "sub_sub_field"]
	local fields = {}

	-- Each command line argument is a field to maintain
	for _, field_str in ipairs(arg) do
		local field = text.split(field_str, ".")
		table.insert(fields, field)
	end

	-- Runs the filter

	local err = parser.handle_input(function(input)
		local output = {}

		for _, field in ipairs(fields) do
			copy_field(input, output, field)
		end

		parser.write_table_output(output)
	end)

	if err then
		return "error handling input: " .. err
	end
end

local err = main()
if err then
	print(err)
end
