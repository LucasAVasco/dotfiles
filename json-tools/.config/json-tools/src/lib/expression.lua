local M = {}

---Dynamically create a function.
---@param arg_list string[]
---@param body string
---@return function fn, string? error
function M.compile_function(arg_list, body)
	-- Compiles the function loader

	local loader, err = load("return function(" .. table.concat(arg_list, ", ") .. ")" .. body .. " end")

	if err then
		return function() end, "error compiling filter expression loader: " .. err
	end

	if type(loader) ~= "function" then
		return function() end, "loader must be a function"
	end

	--- Loads the function

	local func = loader()

	if type(func) ~= "function" then
		return function() end, "filter function must be a function"
	end

	return func
end

return M
