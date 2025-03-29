---Set the database connection to use on the current buffer
local function set_current_buffer_database_conn()
	local conn_list = vim.fn['db_ui#connections_list']()

	---List of open connections
	---@type string[]
	local open_conn_list = {}
	for _, conn in ipairs(conn_list) do
		if conn.is_connected == 1 then
			table.insert(open_conn_list, conn.name)
		end
	end

	if #open_conn_list == 0 then
		vim.notify('There are not open connections!', vim.log.levels.ERROR)
		return
	end

	-- The user should choose the connection to use on the current buffer
	vim.ui.select(open_conn_list, {
		prompt = 'Select the connection to use on the current buffer',
	}, function(selected_item, _)
		if selected_item == nil then
			return
		end

		for _, conn in ipairs(conn_list) do
			if conn.name == selected_item then
				vim.b.db = conn.url
				return -- Does not show the error message
			end
		end

		vim.notify('The selected connection does not exist in the DBUI connection list: ' .. selected_item, vim.log.levels.ERROR)
	end)
end

return {
	{
		'tpope/vim-dadbod',
		cmd = {
			'DB',
		},
	},
	{
		'kristijanhusak/vim-dadbod-completion',
		ft = { 'sql', 'mysql', 'plsql' },
	},
	{
		'kristijanhusak/vim-dadbod-ui',

		dependencies = {
			'tpope/vim-dadbod',
		},

		keys = {
			{ '<leader>MU', '<CMD>DBUIToggle<CR>', desc = 'Toggle database User interface' },
			{ '<leader>MB', set_current_buffer_database_conn, desc = 'Set current buffer database connection' },
		},

		cmd = {
			-- Default commands
			'DBUI',
			'DBUIAddConnection',
			'DBUIFindBuffer',
			'DBUILastQueryInfo',
			'DBUIRenameBuffer',
			'DBUIToggle',

			-- My custom commands
			'DBUISetBufferCompletion',
		},

		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_auto_execute_table_helpers = 1
			-- vim.g.db_ui_debug = 1

			vim.g.db_ui_tmp_query_location = '/tmp/dadbodui-' .. vim.env.USER .. '/'
		end,

		config = function()
			vim.api.nvim_create_autocmd('User', {
				pattern = 'DBUIOpened',
				callback = function()
					vim.api.nvim_buf_set_keymap(0, 'n', 'h', '<Plug>(DBUI_GotoParentNode)', { desc = 'Go to parent node' })
					vim.api.nvim_buf_set_keymap(0, 'n', 'l', '<Plug>(DBUI_SelectLine)', { desc = 'Toggle scope' })
				end,
			})

			-- Command to set the current buffer database connection
			vim.api.nvim_create_user_command(
				'DBUISetBufferCompletion',
				set_current_buffer_database_conn,
				{ desc = 'set the current buffer database connection' }
			)
		end,
	},
}
