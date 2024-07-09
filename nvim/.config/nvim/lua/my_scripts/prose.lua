vim.g.set_prose_default_text_width = 140


-- Create a command tho change between the Prose editing and the normal editing. In the Prose editing, the up and down keys walk
-- trough the same line if it is wrapped into several lines. It is possible to change the text width in the Prose editing.
vim.api.nvim_create_user_command('SetProse', function(arguments)
	-- Check the arguments
	if arguments.fargs[1] ~= 'y' and arguments.fargs[1] ~= 'n' then
		print('Argument 1 must be either "y" or "n"')
		return
	elseif arguments.fargs[2] ~= nil and tonumber(arguments.fargs[2]) == nil then
		print('Argument 2 must be a number, or not provided to use the default value')
		return
	end

	-- Keys that can be mapped in the Prose editing
	local keys_to_map = {'<Up>', '<Down>', 'j', 'k'}

	-- Uses the second argument as the text width, or the default value if no second argument is provided
	local text_width = tonumber(arguments.fargs[2]) or vim.g.set_prose_default_text_width

	if arguments.fargs[1] == 'y' then
		-- General options from Prose editing
		vim.opt_local.textwidth = text_width
		vim.opt_local.linebreak = true

		-- Maps the up and down keys to g<Up> and g<Down>. This makes them walk along the same line if it is wrapped into several lines
		for _, key in ipairs(keys_to_map) do
			vim.api.nvim_buf_set_keymap(0, 'n', key, 'g' .. key, { desc='Walk along the same line if it is wrapped' })
			vim.api.nvim_buf_set_keymap(0, 'v', key, 'g' .. key, { desc='Walk along the same line if it is wrapped' })
		end

	elseif arguments.fargs[1] == 'n' then
		-- General options from Prose editing
		vim.opt_local.textwidth = 0
		vim.opt_local.linebreak = false

		-- Removes the mapping of the up and down keys to work as normal
		for _, key in ipairs(keys_to_map) do
			vim.api.nvim_buf_set_keymap(0, 'n', key, '', {})
			vim.api.nvim_buf_set_keymap(0, 'v', key, '', {})
		end

	else
		print('Invalid argument')
	end
end, {
	nargs = '+',
	complete = MYFUNC.create_complete_function({
		y = {
			'0', '100', '140'  -- Text width
		},
		'n'
	})
})
