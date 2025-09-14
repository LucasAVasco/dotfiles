local exec = require('my_libs.exec')

local file_states = {
	M = 'modified',
	A = 'added',
	D = 'deleted',
	R = 'renamed',
	['?'] = 'unknown',
}

-- Functions {{{

---Get the file path from a line in the fugitive UI.
---@param line string
---@return string file, string? error
local function get_file_from_line(line)
	if line:sub(2, 2) ~= ' ' then
		return '', 'file specification must have a space after the mode'
	end

	local mode = line:sub(1, 1)

	if file_states[mode] == nil then
		return '', 'invalid mode'
	end

	return line:sub(3)
end

---Get the selected files from the fugitive UI.
---@return string[] files, string? error
local function get_selected_files()
	local lines = MYFUNC.get_visual_selected_lines(0)

	---@type string[]
	local files = {}

	for _, line in ipairs(lines) do
		local file, err = get_file_from_line(line)

		if err then
			return {}, ("error getting file from line '%s': %s"):format(line, err)
		end

		table.insert(files, file)
	end

	return files
end

---Execute a Git command.
---@param args string[] Arguments without the 'git' command
---@param callback? fun(out: vim.SystemCompleted)
local function exec_git_command(args, callback)
	-- vim.fn.FugitiveExecute(args)
	exec.System:new({ 'git', unpack(args) }, {}, function()
		vim.schedule(vim.cmd.edit)

		if callback then
			callback(args)
		end
	end)
end

---Unhide all files.
---@param callback? fun(out: vim.SystemCompleted)
local function unhide_files(callback)
	exec_git_command({ 'hide', '-u' }, callback)
end

---Hide the selected files.
---@param callback? fun(out: vim.SystemCompleted)
local function hide_selected_files(callback)
	local files, err = get_selected_files()

	if err then
		return {}, 'error getting selected files: ' .. err
	end

	local args = { 'hide', '--', unpack(files) }
	exec_git_command(args, callback)
end

---Show only the selected files.
---@param callback? fun(out: vim.SystemCompleted)
local function show_only_selected_files(callback)
	local files, err = get_selected_files()

	if err then
		return {}, 'error getting selected files: ' .. err
	end

	local args = { 'only', unpack(files) }
	exec_git_command(args, callback)
end

-- }}}

vim.keymap.set({ 'n', 'v' }, 'zc', function()
	local _, err = hide_selected_files()

	if err then
		vim.notify('error hiding files: ' .. err, vim.log.levels.ERROR)
	end
end, { buffer = true, desc = 'Hide selected files' })

vim.keymap.set({ 'n', 'v' }, 'zo', function()
	local _, err = show_only_selected_files()

	if err then
		vim.notify('error hiding files: ' .. err, vim.log.levels.ERROR)
	end
end, { buffer = true, desc = 'Show only selected files' })

vim.keymap.set({ 'n', 'v' }, 'zr', function()
	unhide_files()
end, { buffer = true, desc = 'Unhide all files' })
