local ls = require('luasnip')
local helper = require('my_plugin_libs.lua_snippets.helm.helper')
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

local nl = function()
	return t({ '', '' })
end

return {
	s({
		trig = 'name',
		name = 'Full name of the app with helper',
		desc = 'Full name of the app with helper',
	}, {
		helper.node('{{ include "HELM_HELPER.fullname" . }}'),
	}),
	s({
		trig = 'labels',
		name = 'Sample labels with helper',
		desc = 'Sample labels with helper',
	}, {
		t('labels:'),
		nl(),
		helper.node('\t{{- include "HELM_HELPER.labels" . | nindent '),
		i(1, '4'),
		t(' }}'),
		nl(),
		t('\tapp.kubernetes.io/component: '),
		i(2, 'component-in-this-chart'),
		nl(),
		helper.node('\tapp.kubernetes.io/part-of: HELM_PART_OF'),
	}),
	s({
		trig = 'selector-content',
		name = 'Selector content with helper',
		desc = 'Selector content with helper',
	}, {
		helper.node('{{- include "HELM_HELPER.selectorLabels" . | nindent '),
		i(1, '4'),
		t(' }}'),
		nl(),
		t('app.kubernetes.io/component: '),
		i(2, 'component-in-this-chart'),
	}),
}
