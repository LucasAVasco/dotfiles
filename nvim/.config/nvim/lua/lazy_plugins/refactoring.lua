-- Keymap callback that loads the actions module only when the keymap is used
local function action(name, ...)
	local args = { ... }
	return function()
		require('temp-print.actions')[name](unpack(args))
	end
end

return {
	'LucasAVasco/temp-print.nvim',
	event = 'VeryLazy',
	cmd = 'TempPrint',
	---@module "temp-print"
	---@type TempPrint.UserOptions
	opts = {
		is_neovim_lua = function(buffer)
			-- Checks if the user is editing a project configuration file (any Lua file inside the project folder)

			local api_project = require('project_runtime_dirs.api.project')
			local project_config_dir = api_project.get_project_configuration_directory()
			if project_config_dir then
				local buffer_path = vim.api.nvim_buf_get_name(buffer)
				if vim.startswith(buffer_path, project_config_dir) then
					return true
				end
			end

			-- Checks if the user is editing a Lua file inside any Neovim configuration file
			return require('temp-print').default_is_neovim_lua(buffer)
		end,
	},
	keys = {
		-- Insertion. In Visual mode, the line prints are inserted for each selected line
		{ '<leader>pl', action('location'), mode = { 'n', 'x' }, desc = 'Print location (after each selected line)' },
		{ '<leader>pL', action('location', -1), desc = 'Print location before the line' },
		{ '<leader>pv', action('variable'), desc = 'Print variable' },
		{ '<leader>pV', action('variable', -1), desc = 'Print variable before the line' },
		{ '<leader>pw', action('variable_with_line'), desc = 'Print line and variable' },
		{ '<leader>pa', action('variable_around'), desc = 'Print variable before and after the line' },
		{ '<leader>pA', action('variable_around_with_line'), desc = 'Print variable around, and the line' },
		{ '<leader>pj', action('previous_line_below'), mode = { 'n', 'x' }, desc = 'Print the line (after it)' },
		{ '<leader>pk', action('next_line_above'), mode = { 'n', 'x' }, desc = 'Print the line (before it)' },

		-- Edition
		{ '<leader>pd', action('delete'), mode = { 'n', 'x' }, desc = 'Delete temporary print(s)' },
		{ '<leader>pD', action('clear_all'), desc = 'Delete all temporary prints' },
		{ '<leader>pc', action('toggle_comment'), mode = { 'n', 'x' }, desc = 'Toggle comment of temporary print(s)' },
		{ '<leader>pC', action('comment_all'), desc = 'Comment all temporary prints' },
		{ '<leader>pU', action('uncomment_all'), desc = 'Uncomment all temporary prints' },
		{ '<leader>pu', action('update'), desc = 'Update temporary prints' },

		-- Navigation
		{ ']p', action('next'), desc = 'Next temporary print' },
		{ '[p', action('prev'), desc = 'Previous temporary print' },
		{ '[P', action('first'), desc = 'First temporary print' },
		{ ']P', action('last'), desc = 'Last temporary print' },

		-- Lists and pickers (use the picker you have installed: telescope, fzf_lua or snacks)
		{ '<leader>pq', action('quickfix'), desc = 'Temporary prints in quickfix' },
		{ '<leader>pQ', action('quickfix_directory'), desc = 'Temporary prints of the directory in quickfix' },
		{
			'<leader>pf',
			function()
				require('temp-print.telescope').buffer()
			end,
			desc = 'Pick temporary prints',
		},
		{
			'<leader>pF',
			function()
				require('temp-print.telescope').directory()
			end,
			desc = 'Pick temporary prints of the directory',
		},

		{ '<leader>ph', action('toggle_highlight'), desc = 'Toggle temporary print highlight' },
	},

	init = function()
		MYPLUGFUNC.load_telescope_extension('temp_print', { 'temp_print', 'directory', 'buffer' })
	end,
}
