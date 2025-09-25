local M = {}

---@class my_plugin_libs.fs.files.copy_options
---@field overwrite? boolean Overwrite the destination file if it exists
---@field notify? boolean Show a notification when the file is copied. Errors are always shown

---Copy a file.
---@param source string Path to the source file.
---@param destination string Path to the destination file.
---@param opts? my_plugin_libs.fs.files.copy_options Options.
---@return boolean success
function M.copy_file(source, destination, opts)
	opts = opts or { notify = true }

	-- Checks if the destination file exists
	if vim.fn.filereadable(destination) == 1 and not opts.overwrite then
		vim.notify('Destination file already exists: ' .. destination, vim.log.levels.ERROR, {
			title = 'File copy',
		})
		return false
	end

	-- Input file handler
	local input = io.open(source, 'rb')
	if not input then
		vim.notify('Could not open source file to read: ' .. source, vim.log.levels.ERROR, {
			title = 'File copy',
		})
		return false
	end

	-- Output file handler
	local output = io.open(destination, 'wb')
	if not output then
		input:close()
		vim.notify('Could not open destination file to write: ' .. destination, vim.log.levels.ERROR, {
			title = 'File copy',
		})
		return false
	end

	-- Copies the file
	local bytes = input:read(10)
	while bytes do
		output:write(bytes)
		bytes = input:read(32768) -- 32768 = 32 KBi
	end

	-- Closes the files
	input:close()
	output:close()

	-- Shows a notification
	if opts.notify then
		vim.notify('Copied "' .. source .. '" to "' .. destination .. '"', vim.log.levels.INFO)
	end

	return true
end

return M
