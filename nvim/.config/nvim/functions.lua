-- Manages the 'uv' and 'loop' interfaces. 'uv', 'vim.uv', 'vim.loop', are all equivalent
uv = vim.uv or vim.loop
vim.uv = vim.uv or uv
vim.loop = vim.loop or uv


-- Global functions go here
_G.myfunc = {}
_G.myplugfunc = {}  -- For plugins


-- #region Utility functions

--- Recursively set a value in a table.
-- This function is analogous to `vim.tbl_get`, but sets the value instead of getting it. If you run:
-- `myfunc.tbl_set({a = {b = {c = 1}}}, {'a', 'b', 'c'}, 2)`, `tbl` will be `{a = {b = {c = 2}}}`.
-- @param tbl Table where the value will be set.
-- @param args List of arguments that defines the element to be set in the table.
-- @param value Value that will be set.
function myfunc.tbl_set(tbl, args, value)
	-- If the `args` is empty, considers that is a insertion
	if #args == 0 then
		table.insert(tbl, value)
	else
		local sub_tbl = tbl

		-- Iterate trough the `tbl`. The `sub_tbl` will be the last element in the table before the `args[#args]`.
		for i = 1, #args-1 do
			local next_tbl = sub_tbl[args[i]]

			if type(next_tbl) ~= 'table' then  -- Creates the `sub_tbl` if it doesn't exist in the table
				next_tbl = {}
				sub_tbl[args[i]] = next_tbl
			end

			sub_tbl = next_tbl
		end

		-- Sets the last `args` element to the corresponding `value`.
		sub_tbl[args[#args]] = value
	end
end


--- Splits a string into a table using a Lua pattern.
-- @param text String to be split
-- @param pattern Pattern used to split the string
-- @return List of strings that are the result of the split
function myfunc.str_split(text, pattern)
	local result = {}

	for value in string.gmatch(text, pattern) do
		table.insert(result, value)
	end

	return result
end

-- #endregion


-- #region Decorators to call vim functions

--- Decorator that returns a Lua function that runs the provided vim function.
-- If you pass more than one argument, the others will be used as the parameters of the provided vim function.
-- @param func String of the name of the vim function.
-- @param args List of arguments that will be passed to the provided vim function.
-- @return A Lua function that runs the provided vim function with the provided arguments.
function myfunc.decorator_call_vim_function(func, args)
	return function()
		return vim.fn[func](unpack(args))
	end
end


--- Decorator that receives a lua function and returns a Lua function that runs it with the provided arguments.
-- The returned function will always call the provided function with these arguments. You don't need to pass them.
-- If you pass more than one argument, the others will be used as the parameters of the provided function.
-- @param func Lua function that will be called.
-- @param args List of arguments that will be passed to the provided function.
-- @return A Lua function that runs the provided function with the provided arguments.
function myfunc.decorator_call_function(func, args)
	return function()
		return func(unpack(args))
	end
end

-- #endregion


-- #region functions to manage colors

--- Converts an decimal number to a hexadecimal form to be used as an color.
-- E.g. '1234567' is converted to '#12d687'.
-- @param integer_value Number in decimal to be converted.
-- @return String of the hexadecimal color.
function myfunc.color_int2hex(integer_value)
	return string.format('#%x', integer_value)
end


--- Normalizes an RGB color.
-- You need to provide its value as an integer and the maximum value to the sum of each color.
-- @param integer_value Number in decimal to be converted.
-- @param sum_each_color Maximum value to the sum of each color.
-- @return String of the hexadecimal color. E.g. '#12d687'.
function myfunc.normalize_rgb(integer_value, sum_each_color)
	local get_color_from_hex = function(hex_value, color_index)
		local hex = string.sub(hex_value, 2*color_index-1, 2*color_index)
		return tonumber(hex, 16)
	end

	hex_color = string.format('%x', integer_value)

	-- Get the RGB as decimal integers (not hexadecimal)
	local red = get_color_from_hex(hex_color, 1)
	local green = get_color_from_hex(hex_color, 2)
	local blue = get_color_from_hex(hex_color, 3)

	-- Eight used to normalize
	local sum = red + green + blue
	local weight = sum_each_color / sum

	-- Output as hex
	local hex_value = string.format('#%02x%02x%02x', red * weight, green * weight, blue * weight)
	return hex_value
end

-- #endregion


-- #region Functions to manage Highlight groups

--- Get the definition of a highlight group (pass through the links to the original highlight group)
-- @param hl_group_name Name of the highlight group
-- @return The definition of the highlight group
function myfunc.get_hl_definition(hl_group_name)
	hl_group_def = vim.api.nvim_get_hl(0, { name = hl_group_name })

	-- When the `link` attribute is nil, it is the original highlight group
	while hl_group_def.link do
		hl_group_def = vim.api.nvim_get_hl(0, { name = hl_group_def.link })
	end

	return hl_group_def
end

-- #endregion


-- #region Functions related to `nvim_create_user_command`


--- Return a list with the possible completions for a command.
-- You need to provide a table with the arguments configuration. If the item is a string, its content is a possible completion.
-- If is a table, the key name is a possible completion, and its contents are the nested completion for its key.
-- E.g: { a = { 'b', 'c' }, 'd' }, can be used to trigger the completions: Command a b, Command a c, Command d.
-- @param current_arg_lead The current argument being completed.
-- @param entire_command The entire command being completed.
-- @param cursor_pos The cursor position.
-- @param arguments_table Table with arguments configuration.
-- @return A list with the possible completions.
function myfunc.get_complete_suggestions(current_arg_lead, entire_command, cursor_pos, arguments_table)
	-- Converts the entire command into a list
	local command_args = {}
	for arg in string.gmatch(entire_command, '[^%s]+') do
		table.insert(command_args, arg)
	end

	table.remove(command_args, 1)  -- Removes the function name

	-- Removes the current argument being completed if it is the last command because the completions will be
	-- in the same depth as the current argument
	if current_arg_lead ~= '' then
		table.remove(command_args, #command_args)
	end

	-- Iterate through the arguments table until the last element (before the current tipping argument)
	local completions = vim.tbl_get(arguments_table, unpack(command_args))  -- If `command_args` is empty, `completions` will be nil

	-- If `command_args` is empty, use the complete with the arguments in the first depth
	if command_args[1] == nil then
		completions = arguments_table
	end

	-- Formats the completions to be returned as a list of strings
	local index = 1
	local response = {}  -- Formated completions
	for key, value in pairs(completions or {}) do
		if type(value) == 'table' then
			response[index] = key
		else
			response[index] = value
		end

		index = index + 1
	end

	-- Removes arguments that does not match the current argument being tipped
	if current_arg_lead ~= '' then
		for i = #response, 1, -1 do
			if not string.match(response[i], '^' .. current_arg_lead) then
				table.remove(response, i)
			end
		end
	end

	return response
end

--- Decorator to create a completion function to be used with 'nvim_create_user_command' function.
-- @param arguments_table Table with arguments configuration. Same as `myfunc.get_complete_suggestions`
-- @return A `complete` function to be used with `nvim_create_user_command`.
function myfunc.create_complete_function(arguments_table)
	return function(current_arg_lead, entire_command, cursor_pos)
		return myfunc.get_complete_suggestions(current_arg_lead, entire_command, cursor_pos, arguments_table)
	end
end

-- #endregion


-- #region Functions related to keymaps.

--- Decorator to create a function that returns a options table equal the `default_options` with the `desc` option overridden.
-- Can be used with function like: `nvim_create_user_command` and `nvim_set_keymap`.
-- Because the `desc` option will be overridden, you should not set it in the `default_options` parameter.
-- @param default_options Options table.
-- @return A function that returns a options table. Format: func(keymap_description: string): table.
function myfunc.decorator_create_options_table(default_options)
	return function(keymap_description)
		return vim.tbl_extend('force', default_options, { desc = keymap_description })
	end
end


-- #region Functions to set keymap names

local is_wichkey_loaded = false    -- If the `which-key` plugin is loaded (required to apply the keymap names)
local which_key_maps_to_load = {}  -- Until the `which-key` plugin is loaded, the keymap names will be stored here


--- Sets the keymap name
-- Does not check if the `which-key` plugin is loaded. This functions is designed to be used in the by other functions to implement
-- the keymap names API, not the final user.
-- @param keymap Keymap code string (same as `nvim_set_keymap`)
-- @param name Keymap name (description) to be show by which-key
-- @param modes Keymap modes (table). E.g { 'n', 'v', 'i' }
local function set_keymap_name(keymap, name, modes)
	require('which-key').register({ [keymap] = name }, { mode = modes })
end


--- Starts the registration of keymap names.
-- All pending keymap names (in the `which_key_maps_to_load` variable) will be registered. This table will be cleared after the
-- update and will not be needed anymore.
-- This function need to be called after the `which-key` plugin is loaded.
function myplugfunc.start_keymap_register()
	for _, map in ipairs(which_key_maps_to_load) do
		set_keymap_name(unpack(map))
	end

	is_wichkey_loaded = true
	which_key_maps_to_load = {}
end


--- Global function to set keymap names (for which-key)
-- Register the keymap names in the `which-key` plugin, or stores it to be registered after the `which-key` plugin is loaded.
-- @param keymap Keymap code string (same as `nvim_set_keymap`)
-- @param name Keymap name (description) to be show by which-key
-- @param modes Keymap modes (table). E.g { 'n', 'v', 'i' }
function myplugfunc.set_keymap_name(keymap, name, modes)
	if is_wichkey_loaded then
		set_keymap_name(keymap, name, modes)
	else
		table.insert(which_key_maps_to_load, { keymap, name, modes })
	end
end

-- #endregion

-- #endregion


-- #region Debug functions

--- Show the elapsed time of a function.
-- Test it multiple times and shows the average value of the elapsed time.
-- Useful for debugging.
-- @param func Function to be executed.
-- @param times Number of times the function will be executed.
-- @param args Arguments to be passed to the function.
function myfunc.show_elapsed_time_function(func, times, args)
	local dbg_start_time = vim.fn.strftime('%Y/%m/%d %T')
	local dbg_time = {}

	for i = 1, times or 1 do
		dbg_time[#dbg_time+1] = vim.fn.reltime()

		func(unpack(args or {}))

		dbg_time[#dbg_time] = vim.fn.reltime(dbg_time[#dbg_time])
	end

	-- Header message
	local dbg_end_time = vim.fn.strftime('%Y/%m/%d %T')
	response = '\n' .. dbg_start_time .. ' - ' .. dbg_end_time .. '\n'

	-- Iteration summary
	sum = 0
	for i = 1, #dbg_time do
		sum = sum + vim.fn.reltimefloat(dbg_time[i])
		response = response .. '\n iteration ' .. i .. ': ' .. vim.fn.reltimestr(dbg_time[i]) .. '\n'
	end

	-- Avarege
	response = response .. '\n average: ' .. sum / #dbg_time .. '\n'

	print(response)
end

-- #endregion
