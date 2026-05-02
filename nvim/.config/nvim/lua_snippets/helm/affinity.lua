local ls = require('luasnip')
local helper = require('my_plugin_libs.lua_snippets.helm.helper')
local s = ls.snippet
local i = ls.insert_node
local d = ls.dynamic_node
local t = ls.text_node
local sn = ls.snippet_node

local nl = function()
	return t({ '', '' })
end

return {
	s({
		trig = 'pod-anti-affinity',
		name = 'Set pod anti-affinity',
		desc = 'Set pod anti-affinity',
	}, {
		t('podAntiAffinity:'),
		nl(),
		t('\trequiredDuringSchedulingIgnoredDuringExecution:'),
		nl(),
		t('\t\t- topologyKey: kubernetes.io/hostname'),
		nl(),
		t('\t\t\tlabelSelector:'),
		nl(),
		t('\t\t\t\tmatchLabels:'),
		nl(),
		d(1, function(_)
			local nodes = {}
			if MYVAR.snippets.helm.helper.enabled then
				nodes = {
					helper.node('\t\t\t\t\t{{- include "HELM_HELPER.selectorLabels" . | nindent '),
					i(1, '18'),
					t(' }}'),
				}
			else
				nodes = {
					t('\t\t\t\t\tapp.kubernetes.io/name: {{ .Chart.Name }}'),
					nl(),
					t('\t\t\t\t\tapp.kubernetes.io/instance: {{ .Release.Name }}'),
				}
			end

			return sn(nil, nodes)
		end, {}),
		nl(),
		t('\t\t\t\t\tapp.kubernetes.io/component: '),
		i(2, 'component-in-this-chart'),
	}),
}
