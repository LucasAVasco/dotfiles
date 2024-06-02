local custom_setup_functions = {}
local custom_setup_functions_completion_table = {}


-- Command to run a setup function
vim.api.nvim_create_user_command('Setup', function(arguments)
	local setup_function = vim.tbl_get(custom_setup_functions, unpack( arguments.fargs ))

	if setup_function ~= nil then
		setup_function()
	else
		print('Invalid argument')
	end
end, {
	nargs = '+',
	complete = function(current_arg_lead, entire_command, cursor_pos)
		local arguments_table = {}

		for setup_name, _ in pairs(custom_setup_functions) do
			table.insert(arguments_table, setup_name)
		end

		return myfunc.get_complete_suggestions(current_arg_lead, entire_command, cursor_pos, custom_setup_functions_completion_table)
	end
})


--- Add a setup command
-- @param setup_name Name of the setup command
-- @param setup_function The setup function
function myfunc.add_setup_command(setup_name, setup_function)
	-- Each argument of the command will be an element of the `command_args` list
	local command_args = myfunc.str_split(setup_name, '[^%s]+')

	myfunc.tbl_set(custom_setup_functions, command_args, setup_function)
	myfunc.tbl_set(custom_setup_functions_completion_table, command_args, {})
end


-- Run all setup functions except 'all'
local function run_all_setup_functions()
	for setup_name, setup_function in ipairs(custom_setup_functions) do
		if setup_name ~= 'all' then
			setup_function(setup_name)
		end
	end
end


myfunc.add_setup_command('all', run_all_setup_functions)
