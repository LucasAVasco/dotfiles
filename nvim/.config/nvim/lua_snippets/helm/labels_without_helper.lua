local ls = require('luasnip')
local helper = require('my_plugin_libs.lua_snippets.helm.helper')
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

-- Disable the snippets if the helper is enabled
if MYVAR.snippets.helm.helper.enabled then
	return {}
end

local nl = function()
	return t({ '', '' })
end

return {
	s({
		trig = 'name',
		name = 'Full name of the app',
		desc = 'Full name of the app',
	}, {
		helper.node('{{ .Release.Name }}-{{ .Chart.Name }}'),
	}),
	s({
		trig = 'labels',
		name = 'Sample labels',
		desc = 'Sample labels',
	}, {
		t('labels:'),
		nl(),
		t('\tapp.kubernetes.io/name: {{ .Chart.Name }}'),
		nl(),
		t('\tapp.kubernetes.io/instance: {{ .Release.Name }}'),
		nl(),
		t('\tapp.kubernetes.io/version: {{ .Chart.AppVersion | quote }}'),
		nl(),
		t('\tapp.kubernetes.io/component: '),
		i(1, 'component-in-this-chart'),
		nl(),
		t('\tapp.kubernetes.io/part-of: '),
		i(2, 'higher-level-component'),
		nl(),
		t('\tapp.kubernetes.io/managed-by: {{ .Release.Service }}'),
		nl(),
		t('\thelm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}'),
	}),
	s({
		trig = 'selector-content',
		name = 'Selector content',
		desc = 'Selector content',
	}, {
		t('app.kubernetes.io/name: {{ .Chart.Name }}'),
		nl(),
		t('app.kubernetes.io/instance: {{ .Release.Name }}'),
		nl(),
		t('app.kubernetes.io/component: '),
		i(1, 'component-in-this-chart'),
	}),
}
