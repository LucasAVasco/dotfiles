---Overrides the function used to open files, links, etc. This is the function used by the `gx` key-map.
---@param path string Path to open.
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.open = function(path)
	vim.system({ 'default_open', path }, {
		detach = true,
	}, function(out)
		local log_level = out.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR

		vim.notify(('Process of file: %s\nExit code: %d\nExit signal %d'):format(path, out.code, out.signal), log_level, {
			title = 'Process exited',
		})
	end)
end
