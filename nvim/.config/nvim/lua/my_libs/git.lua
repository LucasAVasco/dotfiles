local M = {}

---Get the git root directory of the current folder
---@param folder any
---@return string?
function M.get_root_dir(folder)
	return MYFUNC.iter_path(folder, function(path)
		return vim.fn.isdirectory(path .. '/.git') == 1
	end)
end

return M
