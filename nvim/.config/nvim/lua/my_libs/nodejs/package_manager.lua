local M = {}

---Get the package manager from the `package.json` object.
---@param json table Path to the `package.json` file.
---@return string? manager
---@return string? error
function M.get_from_package_json(json)
	---@type string?
	local manager = json['packageManager']

	if not manager or manager == {} then
		return nil -- It is not an error if there is no package manager to the 'package.json'
	end

	if type(manager) ~= 'string' then
		return nil, 'The "packageManager" field is not a string'
	end

	-- The 'packageManager' field has the following format '<package-manager>@<version>'
	-- We need only the package-manager
	return manager:match('^(%w+)@')
end

---Get the package manager from the `package.json` file.
---@param path string Path to the `package.json` file.
---@return string? manager
---@return string? error
function M.get_from_package_json_file(path)
	-- Json object with the content of the 'package.json' file
	local json, err = MYFUNC.get_json_file_content(path)
	if err then
		return nil, 'Failed to load "package.json": ' .. err
	end

	-- Package manager
	local package_manager, err = M.get_from_package_json(json)
	if err then
		return nil, 'Failed to get package manager from the "package.json" object: ' .. err
	end

	return package_manager
end

---Search for a package manager in the current directory.
---@param start_directory string Path to the directory to start the search.
---@return string package_manager
---@return string? error
function M.search(start_directory)
	while true do
		-- Path of the directory that contains the package manager specified in the 'package.json'
		local dir = MYFUNC.iter_path(start_directory, function(dir)
			local package_json = dir .. '/package.json'

			if not MYFUNC.file_exists(package_json) then
				return
			end

			local manager, err = M.get_from_package_json_file(package_json)
			if err then
				return false
			end

			return manager ~= nil
		end)

		if not dir then
			return '', 'No package manager found in any of the "package.json" files of the current and parent directories'
		end

		-- Get the package manager
		local manager, err = M.get_from_package_json_file(dir .. '/package.json')

		if err then
			return '', 'Failed to get package manager from the "package.json" with a "packageManager" field: ' .. err
		end

		if manager == nil then
			return '', 'No package manager found in the "package.json" with a "packageManager" field: '
		end

		return manager
	end
end

return M
