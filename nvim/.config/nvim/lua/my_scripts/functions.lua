-- Manages the 'uv' and 'loop' interfaces. 'uv', 'vim.uv', 'vim.loop', are all equivalent
_G.uv = vim.uv or vim.loop
vim.uv = vim.uv or uv
vim.loop = vim.loop or uv

-- Global functions go here
_G.MYFUNC = {}
_G.MYPLUGFUNC = {} -- For plugins

-- #region Utility functions

--- Recursively set a value in a table.
--- This function is analogous to `vim.tbl_get`, but sets the value instead of getting it. If you run:
--- `MYFUNC.tbl_set({a = {b = {c = 1}}}, {'a', 'b', 'c'}, 2)`, `tbl` will be `{a = {b = {c = 2}}}`.
---@param tbl table Table where the value will be set.
---@param args table List of arguments that defines the element to be set in the table.
---@param value any Value that will be set.
function MYFUNC.tbl_set(tbl, args, value)
	-- If the `args` is empty, considers that is a insertion
	if #args == 0 then
		table.insert(tbl, value)
	else
		local sub_tbl = tbl

		-- Iterate trough the `tbl`. The `sub_tbl` will be the last element in the table before the `args[#args]`.
		for i = 1, #args - 1 do
			local next_tbl = sub_tbl[args[i]]

			if type(next_tbl) ~= 'table' then -- Creates the `sub_tbl` if it doesn't exist in the table
				next_tbl = {}
				sub_tbl[args[i]] = next_tbl
			end

			sub_tbl = next_tbl
		end

		-- Sets the last `args` element to the corresponding `value`.
		sub_tbl[args[#args]] = value
	end
end

---Implement a map with Lua patterns as keys.
---
---Compare the `key` argument with the keys of the `map`. Each key in the `map` is a Lua pattern. Cheeks if the `key` argument matches one
---of the keys of the `map`. If true, returns the value of the entry.
---@param key string Compares this key value with the Lua patterns of the `map`.
---@param map table<string, any> Maps a Lua pattern to a value.
---@return any? Value
function MYFUNC.pattern_map_get(key, map)
	for command_name, command_value in pairs(map) do
		if key:match(command_name) then
			return command_value
		end
	end
end

---Splits a string into a list (table) using a Lua pattern.
---@param text string String to be split.
---@param separator string Pattern used to split the string. It is not included in the result list.
---@return string[] split_list List of strings that are the result of the split.
function MYFUNC.str_split(text, separator)
	local result = {}

	local current_position = 0
	while current_position <= #text do
		local match_start, match_end = text:find(separator, current_position)

		if not match_start or not match_end then
			match_start = #text + 1
			match_end = #text + 1
		end

		---Element of the response
		local element = text:sub(current_position, match_start - 1)
		table.insert(result, element)

		-- Next position
		current_position = match_end + 1
	end

	return result
end

---Checks if a array has a specific value.
---@param array any[] Search by the value in this array.
---@param value any Search by this value in the array.
---@return boolean if_has_value
function MYFUNC.array_has(array, value)
	for _, array_value in ipairs(array) do
		if array_value == value then
			return true
		end
	end

	return false
end

--- Get the ID of the window from the buffer number
--- The user need to provide the buffer number. This function will return the ID of the window associated to this buffer. More that one
--- window can be associated to the same buffer. In this case, this function will select one of them and return. The criteria to select the
--- window ID may change in the future, but the first option will ever be the current window
---@param buffer_nr? number Number of the buffer used to search by windows. If not provided or `0`, use the current buffer
---@return number window_ID ID of the window to associated to the provided buffer
function MYFUNC.get_window_by_buffer(buffer_nr)
	if buffer_nr == nil or buffer_nr == 0 then
		buffer_nr = vim.api.nvim_get_current_buf()
	end

	local window_id = vim.api.nvim_get_current_win()

	if vim.fn.winbufnr(window_id) ~= buffer_nr then -- Overrides if the current window does not have the correct buffer attached to it
		window_id = vim.fn.bufwinid(buffer_nr)
	end

	return window_id
end

---@class (exact) myfunc.visual_selected_area Start and end line of a visual selected area
---@field cursor_line integer Line of the cursor
---@field start_selected_line integer The visual selected area starts in this line

---Return the area of the current visual selected area
---@return myfunc.visual_selected_area
function MYFUNC.get_visual_selected_area()
	return {
		cursor_line = vim.fn.line('.'),
		start_visual_line = vim.fn.line('v'),
	}
end

---Return the number of spaces used by a indentation level.
---@param buffer_num integer Get the indentation level of this buffer.
---@return integer number_of_spaces
function MYFUNC.get_indentation_size(buffer_num)
	local bo = vim.bo[buffer_num]

	local indent_size = bo.shiftwidth

	if indent_size == 0 then
		indent_size = bo.tabstop
	end

	return indent_size
end

---Iterate over a path.
---From the inner to the outer path. Returns the path accepted by the filter function.
---@param path string Iterate through this path.
---@param filter fun(iter_path: string): boolean? Return whether the path should be chosen (returned by the function) or not.
---@return string? Accepted_path
function MYFUNC.iter_path(path, filter)
	local dirname = vim.fs.abspath(path)
	dirname = vim.fs.normalize(dirname)

	-- Runs the filter function on all folders until '/' (also checked)
	while true do
		local res = filter(dirname)

		if res then
			return dirname
		end

		-- Last checked directory
		if dirname ~= '/' then
			return
		end

		-- Next directory
		dirname = vim.fs.dirname(dirname)
	end
end

---Get a list of all buffers that matches a specific file-type.
---@param filetype string
---@return integer[]
function MYFUNC.get_buffers_of_filetype(filetype)
	---@type table<integer, boolean>
	local buffers = {}

	for _, tab_page in ipairs(vim.api.nvim_list_tabpages()) do
		for _, buffer_num in ipairs(vim.fn.tabpagebuflist(tab_page)) do
			buffers[buffer_num] = true
		end
	end

	---@type integer[]
	local res = {}
	for buffer_br, _ in pairs(buffers) do
		if vim.bo[buffer_br].filetype == filetype then
			table.insert(res, buffer_br)
		end
	end

	return res
end

---Reset the file type of all buffers that are of this file type. E.g.: `reset_filetype('markdown')` sets the file types of all markdown
---files to 'markdown'. This throws the 'FileType' event to all markdown files.
---
---Useful if you want to attach some plug-in to a file type, but their file type is already defined (before plug-in loads).
---@param filetype any
function MYFUNC.reset_filetype(filetype)
	local buffers = MYFUNC.get_buffers_of_filetype(filetype)
	for _, buffer_nr in ipairs(buffers) do
		vim.bo[buffer_nr].filetype = filetype
	end
end

-- #endregion

-- #region File management functions

---Return `true` if the file exists (is readable) and `false` otherwise.
---@param path string
---@return boolean
function MYFUNC.file_exists(path)
	return vim.fn.filereadable(path) == 1
end

---Get the absolute path of a relative path.
---Also normalize the path.
---@param path string Path of the file. If it is an absolute path, this function only normalizes it.
---@param base_dir string? Base directory of the relative path.
---@return string
function MYFUNC.absolute_path(path, base_dir)
	if base_dir and path:sub(1, 1) ~= '/' then
		path = base_dir .. '/' .. path
	end

	path = vim.fs.normalize(path)
	return vim.fs.abspath(path)
end

---Read a file and convert its contents to Json.
---@param path string File path.
---@return {} content, boolean file_readable
function MYFUNC.get_json_file_content(path)
	if not MYFUNC.file_exists(path) then
		return {}, false
	end

	local lines = vim.fn.readfile(path, 'b')
	local content = table.concat(lines)
	return vim.json.decode(content), true
end

---Get a character in the current line. The character position is relative to the cursor column. A offset equal to 1 returns the character
---in the current column. You can provide 0 and negative values.
---@param col_offset integer Offset applied to the cursor column before getting the character. 1 is the current column.
---@return string char Returns the character or a empty string if can not get the character.
function MYFUNC.get_current_line_char(col_offset)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local col = cursor[2] + col_offset

	return vim.api.nvim_get_current_line():sub(col, col)
end

-- #endregion

-- #region Decorators to call vim functions

--- Decorator that returns a Lua function that runs the provided vim function.
--- If you pass more than one argument, the others will be used as the parameters of the provided vim function.
---@param func string Name of the vim function.
---@param args table List of arguments that will be passed to the provided vim function.
---@return fun() decorated_function A Lua function that runs the provided vim function with the provided arguments.
function MYFUNC.decorator_call_vim_function(func, args)
	return function()
		return vim.fn[func](unpack(args))
	end
end

--- Decorator that receives a lua function and returns a Lua function that runs it with the provided arguments.
--- The returned function will always call the provided function with these arguments. You don't need to pass them.
--- If you pass more than one argument, the others will be used as the parameters of the provided function.
---@param func fun(args: table) Lua function that will be called.
---@param args table List of arguments that will be passed to the provided function.
---@return fun() decorated_function A Lua function that runs the provided function with the provided arguments.
function MYFUNC.decorator_call_function(func, args)
	return function()
		return func(unpack(args))
	end
end

-- #endregion

-- #region functions to manage colors

--- Converts an decimal number to a hexadecimal form to be used as an color.
--- E.g. '1234567' is converted to '#12d687'.
---@param integer_value number Number in decimal to be converted.
---@return string hexadecimal_color
function MYFUNC.color_int2hex(integer_value)
	return string.format('#%x', integer_value)
end

--- Converts a hexadecimal form to be used as an color to a decimal number.
--- E.g. '#12d687' is converted to '1234567'. If you need a function to convert a hexadecimal to integer without the leading `#`, use
--- the `tonumber()` function
---@param hex_value string Hexadecimal color, with a leading `#`.
---@return number decimal_value
function MYFUNC.color_hex2int(hex_value)
	return tonumber(string.sub(hex_value, 2), 16)
end

--- Normalizes an RGB color.
--- You need to provide its value as an integer and the maximum value to the sum of each color.
---@param integer_value number Decimal value to be converted.
---@param sum_each_color number Maximum value to the sum of each color.
---@return string hexadecimal_color. E.g. '#12d687'.
function MYFUNC.normalize_rgb(integer_value, sum_each_color)
	local get_color_from_hex = function(hex_value, color_index)
		local hex = string.sub(hex_value, 2 * color_index - 1, 2 * color_index)
		return tonumber(hex, 16)
	end

	local hex_color = string.format('%x', integer_value)

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
---@param hl_group_name string Name of the highlight group
---@return vim.api.keyset.hl_info highlight_definition The highlight definition of the highlight group
function MYFUNC.get_hl_definition(hl_group_name)
	local hl_group_def = vim.api.nvim_get_hl(0, { name = hl_group_name })

	-- When the `link` attribute is nil, it is the original highlight group
	while hl_group_def.link do
		hl_group_def = vim.api.nvim_get_hl(0, { name = hl_group_def.link })
	end

	return hl_group_def
end

--- Variable to store the file type that the user should not apply highlight groups to
--- Some windows have special use cases and configuration that applies special highlight groups. Example: a dashboard and a 'help'
--- window (like the ones that ':h' open). The user should not change the highlight groups in these windows. This variable stores the
--- file type that the user should not apply highlight groups to. It will be used by the 'user_can_change_appearance' function
MYVAR.ft_to_disable_user_appearance = { 'help' }

--- Returns if the user can change the appearance of the window
--- Some windows have special use cases and configuration that require special appearance. Example: a dashboard and a 'help'
--- window (like the ones that ':h' open). The user should not change the appearance of these windows. This function checks
--- if the provided window or buffer has a special use case and returns if the user can customize its appearance.
--- The user need to provide the window ID or the buffer number. At least one must be provided
---@param window_id? number ID of the window
---@param buffer_nr? number ID of the buffer
---@return boolean can_highlight If the user can apply highlight groups to the window, return true. If not, return false.
function MYFUNC.user_can_change_appearance(window_id, buffer_nr)
	-- Automatically queries the not provided parameters
	window_id = window_id or MYFUNC.get_window_by_buffer(buffer_nr)

	if window_id < 0 then -- Invalid window
		return false
	end

	buffer_nr = buffer_nr or vim.api.nvim_win_get_buf(window_id)

	if buffer_nr < 0 then -- Invalid buffer
		return false
	end

	local filetype = vim.bo[buffer_nr].filetype

	-- The user only can add highlight groups to normal windows (buftype == '')
	if vim.bo[buffer_nr].buftype ~= '' then
		return false
	end

	-- The filetype will be text, c, cpp, editable files. If Neovim is started without a file, this option will be empty
	-- and the function will return false. This prevents the user from change the appearance to special windows that has not set
	-- a filetype already, but requires that the user manually provides a file to edit. Otherwise, the function will return false
	-- even if the file allows the user to change the appearance
	if filetype == '' then
		return false
	end

	-- Manually disable the highlight groups for some file types
	if vim.tbl_contains(MYVAR.ft_to_disable_user_appearance, filetype) then
		return false
	end

	-- Fallback to true if no special use case
	return true
end

-- #endregion

-- #region Functions related to `nvim_create_user_command`

--- Return a list with the possible completions for a command.
--- You need to provide a table with the arguments configuration. If the item is a string, its content is a possible completion. If it is a
--- table, the key name is a possible completion, and its contents are the nested completion for its key. E.g: { a = { 'b', 'c' }, 'd' },
--- can be used to trigger the completions: `Command a b`, `Command a c`, `Command d`. This function is designed to be used with the
--- complete attribute of the `nvim_create_user_command` options table.
---@param current_arg_lead string The current argument being completed.
---@param entire_command string The entire command being completed.
---@param cursor_pos number The cursor position.
---@param arguments_table table Table with arguments configuration.
---@return table completions_suggestion A list with the possible completions.
---@diagnostic disable-next-line: unused-local
function MYFUNC.get_complete_suggestions(current_arg_lead, entire_command, cursor_pos, arguments_table)
	-- Converts the entire command into a list
	local command_args = {}
	for arg in string.gmatch(entire_command, '[^%s]+') do
		table.insert(command_args, arg)
	end

	table.remove(command_args, 1) -- Removes the function name

	-- Removes the current argument being completed if it is the last command because the completions will be
	-- in the same depth as the current argument
	if current_arg_lead ~= '' then
		table.remove(command_args, #command_args)
	end

	-- Iterate through the arguments table until the last element (before the current tipping argument)
	local completions = vim.tbl_get(arguments_table, unpack(command_args)) -- If `command_args` is empty, `completions` will be nil

	-- If `command_args` is empty, use the complete with the arguments in the first depth
	if command_args[1] == nil then
		completions = arguments_table
	end

	-- Formats the completions to be returned as a list of strings
	local index = 1
	local response = {} -- Formatted completions
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
--- The *arguments_table* parameter must be constant. If you need dynamic arguments to the completion function, try the
--- `MYFUNC.get_complete_suggestions` function
---@param arguments_table table Table with arguments configuration. Same as `MYFUNC.get_complete_suggestions`
---@return fun(current_arg_lead: string, entire_command: string, cursor_pos: number): table<string> complete_function
function MYFUNC.create_complete_function(arguments_table)
	return function(current_arg_lead, entire_command, cursor_pos)
		return MYFUNC.get_complete_suggestions(current_arg_lead, entire_command, cursor_pos, arguments_table)
	end
end

---Get the command handler from its arguments.
---
---@param fargs string[] Arguments of the command.
---@param map_cmd_to_handler table<string, any> Maps each command (separated by a single space ' ') to its handler.
---@return any?
function MYFUNC.get_fargs_handler(fargs, map_cmd_to_handler)
	local args = table.concat(fargs, ' ')

	---The command (fargs) must match the full key
	local map = {}
	for key, value in pairs(map_cmd_to_handler) do
		map['^' .. key .. '$'] = value
	end

	return MYFUNC.pattern_map_get(args, map)
end

-- #endregion

-- #region Functions to manage diagnostics

---Resets all diagnostics (`vim.diagnostic` API).
---
---This function is equivalent to clearing all diagnostics and setting them later.
function MYFUNC.reset_diagnostics()
	local namespaces = vim.diagnostic.get_namespaces()

	for namespace_id, _ in pairs(namespaces) do
		local namespace_diagnostics = vim.diagnostic.get(nil, { namespace = namespace_id })

		---Table that relates each buffer to its diagnostics (at the current name-space)
		---@type table<integer, vim.Diagnostic[]>
		local buffer_to_diagnostics = {}

		for _, diagnostic in ipairs(namespace_diagnostics) do
			vim.diagnostic.set(namespace_id, 0, namespace_diagnostics, {})
			local buffer_number = diagnostic.bufnr --[[@as integer]]

			if buffer_to_diagnostics[buffer_number] == nil then
				buffer_to_diagnostics[buffer_number] = {}
			end

			table.insert(buffer_to_diagnostics[buffer_number], diagnostic)
		end

		-- Resets the diagnostics
		for buffer_number, diagnostics in pairs(buffer_to_diagnostics) do
			-- Each call to `vim.diagnostics.set`overrides the last diagnostics of the given names-pace and buffer number. So you must set
			-- all diagnostics related to a name-space and buffer at the same time
			vim.diagnostic.reset(namespace_id, buffer_number)
			vim.diagnostic.set(namespace_id, buffer_number, diagnostics, {})
		end
	end
end

-- #endregion

-- #region Functions related to key maps.

--- Decorator to create a function that returns a options table equal the `default_options` with the `desc` option overridden.
--- This function is useful if the you need to create a lot of key maps with the same options, but with different description. You can
--- provide the default options with to create the `keymap_table_generator`. After this, you can generate the new option tables with a new
--- description by passing the description to this generator. Can be used with function like: `nvim_create_user_command` and
--- `nvim_set_keymap`. Because the `desc` attribute will be overridden, you should not set it in the `default_options` parameter.
---@param default_options vim.keymap.set.Opts Options table.
---@return fun(keymap_description: string): vim.keymap.set.Opts keymap_table_generator A function that returns a key map options table
function MYFUNC.decorator_create_options_table(default_options)
	return function(keymap_description)
		return vim.tbl_extend('force', default_options, { desc = keymap_description })
	end
end

-- #region Functions to set key map names

MYVAR.is_wichkey_loaded = false -- If the `which-key` plugin is loaded (required to apply the keymap names)
local which_key_maps_to_load = {} -- Until the `which-key` plugin is loaded, the keymap names will be stored here

--- Sets the key map name
--- Does not check if the `which-key` plugin is loaded. This functions is designed to be used by other functions to implement the key map
--- names API. The user should not use this function
---@param keymap string Key map code string (same as `vim.keymap.set`)
---@param name string Key map name (description) to be show by which-key
---@param modes? string|table<string> Key map modes. E.g { 'n', 'v', 'i' } or 'n'. Same as `vim.keymap.set`
local function set_keymap_name(keymap, name, modes)
	require('which-key').add({ keymap, desc = name, mode = modes })
end

--- Load all pending key maps with `which-key`
--- All pending key map names (in the `which_key_maps_to_load` variable) will be added. This table will be cleared after the update and will
--- be no longer necessary. Any next call to `MYPLUGFUNC.set_keymap_name()` will load the key maps with `which-key` instead of adding it to
--- 'which_key_maps_to_load'. This function only needs to be called once after the `what-key` plugin setup
function MYPLUGFUNC.load_pending_keymaps()
	for _, map in ipairs(which_key_maps_to_load) do
		set_keymap_name(unpack(map))
	end

	MYVAR.is_wichkey_loaded = true
	which_key_maps_to_load = nil
end

--- Global function to set key map names (with `which-key`)
--- Add the key map names with the `which-key` plugin, or stores it to be added after the `which-key` plugin setup
---@param keymap string Key map code string (same as `vim.keymap.set`)
---@param name string Key map name (description) to be show by which-key
---@param modes? string|table<string> Key map modes. E.g { 'n', 'v', 'i' } or 'n'. Same as `vim.keymap.set`
function MYPLUGFUNC.set_keymap_name(keymap, name, modes)
	if MYVAR.is_wichkey_loaded then
		set_keymap_name(keymap, name, modes)
	else
		table.insert(which_key_maps_to_load, { keymap, name, modes })
	end
end

-- #endregion

-- #endregion

-- #region Debug functions

--- Show the elapsed time of a function.
--- Test it multiple times and shows the average value of the elapsed time.
--- Useful for debugging.
---@param func fun(args: table) Function to be executed.
---@param times number Number of times the function will be executed.
---@param args table Arguments to be passed to the function.
function MYFUNC.show_elapsed_time_function(func, times, args)
	local dbg_start_time = vim.fn.strftime('%Y/%m/%d %T')
	local dbg_time = {}

	for _ = 1, times or 1 do
		dbg_time[#dbg_time + 1] = vim.fn.reltime()

		func(unpack(args or {}))

		dbg_time[#dbg_time] = vim.fn.reltime(dbg_time[#dbg_time])
	end

	-- Header message
	local dbg_end_time = vim.fn.strftime('%Y/%m/%d %T')
	local response = '\n' .. dbg_start_time .. ' - ' .. dbg_end_time .. '\n'

	-- Iteration summary
	local sum = 0
	for i = 1, #dbg_time do
		sum = sum + vim.fn.reltimefloat(dbg_time[i])
		response = response .. '\n iteration ' .. i .. ': ' .. vim.fn.reltimestr(dbg_time[i]) .. '\n'
	end

	-- Average
	response = response .. '\n average: ' .. sum / #dbg_time .. '\n'

	print(response)
end

-- #endregion
