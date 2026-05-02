local ls = require('luasnip')
local f = ls.function_node

local M = {}

local helper = MYVAR.snippets.helm.helper.name or 'helm' -- Default to `helm`
local part_of = MYVAR.snippets.helm.helper.part_of or 'part-of' -- Default to `part-of`

---Replace any occurrence of the Helm variables in the lines with the value of the helper variables
---Replaces the following variables: HELM_HELPER, HELM_PART_OF
---@param lines string|string[] Replace in all lines of this variable
function M.replace_in_string(lines)
	--- Lines as list of strings
	---@type string[]
	local lines_list = {}
	if type(lines) == 'string' then
		lines_list = { lines }
	else
		lines_list = lines
	end

	-- Output of the replacements
	local output = {}
	for _, line in pairs(lines_list) do
		line = line:gsub('HELM_HELPER', helper)
		line = line:gsub('HELM_PART_OF', part_of)
		table.insert(output, line)
	end

	return output
end

---Replace any occurrence of the Helm variables in the provided user argument with the value of the helper variables
---@param user_args string|string[] Replace in all lines of this variable
---@return string[]
local function replace_helper_callback(_, _, user_args)
	return M.replace_in_string(user_args)
end

---Node that replaces the any occurrence of the Helm variables in the provided lines with the value of the helper variables
---@see M.replace_in_string for the list of available replacements
---@param lines string|string[]
---@return LuaSnip.Node
function M.node(lines)
	return f(replace_helper_callback, {}, { user_args = { lines } })
end

return M
