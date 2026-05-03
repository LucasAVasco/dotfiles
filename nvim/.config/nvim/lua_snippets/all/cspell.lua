local ls = require('luasnip')
local s = ls.snippet
local c = ls.choice_node
local t = ls.text_node
local i = ls.insert_node
local sn = ls.snippet_node
local d = ls.dynamic_node

---Map each setting to a list of optional arguments (examples) that can be provided
---@type table<string, string[]>
local settings = {
	-- INFO(LucasAVasco):These settings should be used together to create a section that ignores cSpell, so there are a snippet only for
	-- create the section
	--
	-- 'disable',
	-- 'enable',

	['disable-line'] = {},
	['disable-next-line'] = {},
	['ignore'] = { 'word1 word2 word3' },
	['words'] = { 'word1 word2 word3' },
	['ignoreRegExp'] = { '[0-9a-fA-F]+' },
	['includeRegExp'] = { '[0-9a-fA-F]+' },
	['enableCompoundWords'] = {},
	['disableCompoundWords'] = {},
	['dictionaries'] = {},
}

---@type LuaSnip.Node[]
local choices = {}
for setting, _ in pairs(settings) do
	table.insert(choices, t(setting))
end

return {
	s({
		trig = 'cspell-setting',
		name = 'cSpell setting',
		desc = 'Set cSpell setting in document',
	}, {
		t('cSpell:'),
		c(1, choices),
		d(2, function(args)
			local setting_name = args[1][1]
			local arguments = settings[setting_name]

			---Arguments converted to nodes
			---@type LuaSnip.Node[]
			local nodes = {}
			for index, value in ipairs(arguments) do
				table.insert(nodes, t(' '))
				table.insert(nodes, i(index, value))
			end

			-- Add an arguments separated by a space
			return sn(nil, nodes)
		end, { 1 }),
	}),

	s({
		trig = 'cspell-disable',
		name = 'cSpell disable section',
		desc = 'Add section that disables cSpell',
	}, {
		t('cSpell:disable'),
		i(1, ''),
		t('cSpell:enable'),
	}),
}
