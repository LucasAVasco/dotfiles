require("lib.help").handle_help_message([[
Deletes fields from the input.

USAGE
del-field [-h | --help]
	Show this help message.

del-field <field...>
	Deletes the given fields from the input rows. You can specify sub-fields with a dot. Example: `top_field.sub_field.sub_sub_field`.
]])

local parser = require("lib.json_parser")
local text = require("lib.text")

---Delete a single field from a table (with recursive access).
---@param object table Object to delete the field.
---@param field string[] Field to delete. e.g. ["top_field", "sub_field", "sub_sub_field"]
local function delete_field(object, field)
	local sub_object = object
	local sub_field = field[1]

	-- Traverses the object until the parent object of the last field
	for i = 1, #field - 1 do
		if sub_field == nil then
			return -- Field does not exist
		end

		sub_field = field[i]
		sub_object = sub_object[sub_field]
	end

	-- Deletes the last field on its parent object
	sub_object[field[#field]] = nil
end

---@return string?
local function main()
	---@type string[][] List of fields to delete. Each field is a list of strings, e.g. ["top_field", "sub_field", "sub_sub_field"]
	local fields = {}

	-- Each command line argument is a field to delete
	for _, field_str in ipairs(arg) do
		local field = text.split(field_str, ".")
		table.insert(fields, field)
	end

	-- Runs the filter

	local err = parser.handle_input(function(input)
		for _, field in ipairs(fields) do
			delete_field(input, field)
		end

		parser.write_table_output(input)
	end)

	if err then
		return "error handling input: " .. err
	end
end

local err = main()
if err then
	print(err)
end
