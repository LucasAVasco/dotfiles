local M = {}

---Split a string into a list.
---@param str string String to split.
---@param separator string Separator.
---@return string[]
function M.split(str, separator)
	local list = {}

	---@type integer?
	local last_stop = 0
	local start, stop

	while true do
		start, stop = str:find(separator, last_stop + 1, true)

		if start == nil then
			break
		end

		-- Insert the current token
		local token = string.sub(str, last_stop + 1, start - 1)
		table.insert(list, token)

		-- Next time, start after the separator
		last_stop = stop
	end

	-- Insert the last token
	local token = string.sub(str, last_stop + 1)
	table.insert(list, token)

	return list
end

---Escape a string.
---@param text string
---@return string
function M.escape(text)
	local res = text:gsub("\n", "\\n"):gsub("\r", "\\r")
	return res
end

return M
