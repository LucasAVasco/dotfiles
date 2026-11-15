local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node

return {
	s({
		trig = 'ignore-formatter',
		name = 'Ignore code formatter',
		desc = 'Add comments to ignore code formatter',
	}, {
		d(1, function(_)
			local filetype = vim.bo.filetype
			local file_path = vim.api.nvim_get_runtime_file(('lua/my_configs/formatter/ignore/%s.txt'):format(filetype), false)[1]

			-- Generates nothing if file type is not supported
			if file_path == nil then
				return sn(nil, { t('') })
			end

			-- Read file
			local file, err = io.open(file_path, 'r')
			if not file then
				vim.notify(('Can not read file "%s": %s'):format(file_path, err), vim.log.levels.ERROR, {
					title = 'Ignore formatter snippets',
				})
				return sn(nil, { t('') })
			end

			---@type string
			local content = file:read('*a')
			file:close()

			-- Create the nodes
			local nodes = {}
			local content_splitted = MYFUNC.str_split(content, '%$%d+')
			for item_index, single_split in ipairs(content_splitted) do
				local lines = MYFUNC.str_split(single_split, '\n')
				table.insert(nodes, t(lines))
				table.insert(nodes, i(item_index))
			end

			return sn(nil, nodes)
		end, {}),
	}),
}
