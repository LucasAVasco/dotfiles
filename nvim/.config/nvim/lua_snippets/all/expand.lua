local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local d = ls.dynamic_node
local extras = require('luasnip.extras')


--- Return the snippet structure of the 'expand(%d+)' pattern
---@param args_text table<string> COntent of the nodes that the dynamic node depends on
---@param parent any Parent snippet of the node
---@param old_state any Data of the previous generated snippet
---@param user_args any User provided arguments
---@diagnostic disable-next-line: unused-local
local function d_expand(args_text, parent, old_state, user_args)
	local num_expands=tonumber(parent.captures[1]) or 1

	local nodes = {
		i(1, 'prefix.'),
		i(4, '( index 1 )'),
		i(2, '.suffix'),
		i(3, '( separator )'),
	}

	if num_expands > 1 then
		for index = 2, num_expands do
			table.insert(nodes, extras.rep(1))                                     -- Prefix
			table.insert(nodes, i(index+3, '( index' .. tostring(index) .. ' )'))  -- Entry
			table.insert(nodes, extras.rep(2))                                     -- Suffix

			-- The separator will not be added to the last entry
			if index < num_expands then
				table.insert(nodes, extras.rep(3))
			end
		end
	end

	return sn(nil, nodes)
end


return {
	s({
		trigEngine = 'pattern',
		trig = 'expand(%d+)',
		name = 'expand (prefix)(entry A)(suffix)(separator)...',
		desc = 'Expand text entries and repeat the same prefix and suffix. Each entry will be separated by a provided separator',
	}, {
		d(1, d_expand),
	})
}
