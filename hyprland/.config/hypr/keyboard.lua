local M = {}

function file_exists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end
	return false
end

---Gets the keyboard layouts.
---@return table<string, string> KeyboardToLayout Map each keyboard name to its layout.
function M.get_keyboard_layout_map()
	local dir = os.getenv("HOME") .. "/.local/state/custom-desktop/"
	local file_path = dir .. "/keyboard-layouts"

	if not file_exists(file_path) then
		return {}
	end

	local response = {}
	for line in io.lines(file_path) do
		---@cast line string
		local index = line:find("\t", 0, true)
		assert(index, "Can not find separator")

		local device = line:sub(0, index - 1)
		local layout = line:sub(index + 1, #line)
		response[device] = layout
	end

	return response
end

return M
