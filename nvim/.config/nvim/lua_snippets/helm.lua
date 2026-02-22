local ls = require('luasnip')
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node
local t = ls.text_node

local nl = function()
	return t({ '', '' })
end

--- Replace any occurrence of `HELM_HELPER` in the first user argument with the value of the `HELM_HELPER` environment variable
---@param user_args string|string[] Replace in all lines of this variable
---@return string[]
local function replace_helper_callback(_, _, user_args)
	--- List of input arguments
	local input = {}
	if type(user_args) == 'string' then
		input = { user_args }
	else
		input = user_args
	end

	--- Output arguments
	local output = {}
	local helper = vim.env.HELM_HELPER or 'helm' -- Default to `helm`
	for _, line in pairs(input) do
		line = line:gsub('HELM_HELPER', helper)
		table.insert(output, line)
	end

	return output
end

--- Node that replaces the any occurrence of `HELM_HELPER` in the provided lines with the value of the `HELM_HELPER` environment variable
---@param lines string|string[]
---@return LuaSnip.Node
local function replace_helper(lines)
	return f(replace_helper_callback, {}, { user_args = { lines } })
end

return {
	s({
		trig = 'name',
		name = 'Full name of the app with helper',
		desc = 'Full name of the app with helper',
	}, {
		replace_helper('name: {{ include "HELM_HELPER.fullname" . }}'),
	}),
	s({
		trig = 'labels',
		name = 'Sample labels with helper',
		desc = 'Sample labels with helper',
	}, {
		t('labels:'),
		nl(),
		replace_helper('\t{{- include "HELM_HELPER.labels" . | nindent '),
		i(1, '4'),
		t(' }}'),
		nl(),
		t('\tapp.kubernetes.io/component: '),
		i(2, 'component-in-this-chart'),
		nl(),
		t('\tapp.kubernetes.io/part-of: '),
		i(3, 'higher-level-component'),
	}),
	s({
		trig = 'selector-content',
		name = 'Selector content with helper',
		desc = 'Selector content with helper',
	}, {
		replace_helper('{{- include "HELM_HELPER.selectorLabels" . | nindent '),
		i(1, '4'),
		t(' }}'),
		nl(),
		t('app.kubernetes.io/component: '),
		i(2, 'component-in-this-chart'),
	}),
}
