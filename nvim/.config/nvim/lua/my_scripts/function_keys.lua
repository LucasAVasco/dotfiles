--[[
	API change the behavior of the function keys at runtime

	Allow create table of key mappings that changes the function keys behavior at runtime. Use the `MYFUNC.set_fkey_mappings()` to it and
	`MYFUNC.get_fkeys_mappings()` to get the current configured ones
]]

---@alias MyKeyMapping (fun()|string)

---List of key mappings that can be applied to the function keys.
---@class (exact) MyFunctionKeysMappings
---@field normal MyKeyMapping[] Triggered when the user press <F1>, <F2>, etc.
---@field shift MyKeyMapping[] Triggered when the user press <S-F1>, <S-F2>, etc.

---Execute these mappings when pressing a function key.
---Example: press <F1>, execute `fkeys_mappings.normal[1]`. Press <S-F1>, execute `fkeys_mappings.shift[1]`
---@type MyFunctionKeysMappings
local fkeys_mappings = {
	normal = {},
	shift = {},
}

---Run a function key mapping.
---@param index number Index of the function key to execute. Example: 3 will execute `<F3>`)
---@param shift? boolean If the key has a shift modifier
local function run_fkey(index, shift)
	local func
	if shift then
		func = fkeys_mappings.shift[index]
	else
		func = fkeys_mappings.normal[index]
	end

	local tp = type(func)

	if tp == 'string' then
		vim.api.nvim_feedkeys(func, 'n', true)
	elseif tp == 'function' then
		func()
	end
end

---Get the current configured function keys mappings
---@return MyKeyMapping[]
---@nodiscard
function MYFUNC.get_fkeys_mappings()
	return fkeys_mappings
end

---Saves the last configured `fkeys_mappings`
local last_fkeys_mappings = nil

---Override the function key mappings.
---You need to provide an array with the mappings that will be called when the user press a function key.
---Example: press <F1>, execute `new_fkeys_functions[1]`.
---You can run a function key immediately after override the last ones with the `fkey_to_run` argument. This function will run the function
---key defined by this index. Useful to automatically change the function key behavior in a key mapping. Example:
---```lua
---vim.keymap.set('n', ']d', function()
---    MYFUNC.set_fkey_mappings(new_fkeys_mappings, 2) -- Update the function key mappings and run <F2>
---end)
---```
---If you change the `new_fkeys_mappings`, you need to set `force` to `true`. Otherwise, this function will not apply the changes.
---@param new_fkeys_mappings MyFunctionKeysMappings New mappings. Functions will be called. Strings will be feed with `nvim_feedkeys()`
---@param fkey_to_run? number Index of the function key to execute after override the last ones
---@param shift? boolean If the key has a shift modifier
---@param force? boolean Force the update even if `new_fkeys_mappings` is the current function key mappings.
function MYFUNC.set_fkey_mappings(new_fkeys_mappings, fkey_to_run, shift, force)
	if force or new_fkeys_mappings ~= last_fkeys_mappings then
		fkeys_mappings = {
			shift = {},
			normal = {},
		}
		for index, new_map in pairs(new_fkeys_mappings.shift) do
			if type(new_map) == 'string' then
				new_map = vim.api.nvim_replace_termcodes(new_map, true, true, true)
			end

			fkeys_mappings.shift[index] = new_map
		end
		for index, new_map in pairs(new_fkeys_mappings.normal) do
			if type(new_map) == 'string' then
				new_map = vim.api.nvim_replace_termcodes(new_map, true, true, true)
			end

			fkeys_mappings.normal[index] = new_map
		end
	end

	-- Only runs a function key if the user provided one
	if fkey_to_run ~= nil then
		run_fkey(fkey_to_run, shift)
	end
end

---Like `MYPLUG,set_fkey_mappings()` but, return a function that applies the new function key mappings.
---Useful to automatically change the function key behavior in a key mapping. Example:
---```lua
---vim.keymap.set('n', ']d', MYFUNC.decorator_set_fkey_mappings(new_fkeys_mappings, 2)) -- Update the <Fn> mappings and run <F2>
---```
---If you change the `new_fkeys_mappings`, you need to set `force` to `true`. Otherwise, this function will not apply the changes.
---@param new_fkeys_mappings MyFunctionKeysMappings New mappings. Functions will be called. Strings are feed with `nvim_feedkeys()`
---@param fkey_to_run? number Index of the function key to execute after override the last ones
---@param shift? boolean If the key has a shift modifier
---@param force? boolean Force the update even if `new_fkeys_mappings` is the current function key mappings.
---@return fun() decorated_function Run this function to apply the new function keys mappings
function MYFUNC.decorator_set_fkey_mappings(new_fkeys_mappings, fkey_to_run, shift, force)
	return MYFUNC.decorator_call_function(MYFUNC.set_fkey_mappings, { new_fkeys_mappings, fkey_to_run, shift, force })
end

-- Function keys mappings {{{

local get_opts = MYFUNC.decorator_create_options_table({ remap = false, silent = true })

for fkey_index = 1, 8 do
	vim.keymap.set({ 'n', 'v', 'i' }, '<F' .. fkey_index .. '>', function()
		run_fkey(fkey_index)
	end, get_opts('Function key ' .. fkey_index))

	-- NOTE(LucasAVasco): The <S-Fn> keys are not recognized by Neovim. It may recognize other values when pressing Shift + Function key. To
	-- fix it, you need to remap the recognized keys to <S-Fn> as the following code snippet
	--
	-- ```lua
	-- local opts = {
	--     remap = true,  -- Required
	--     silent = true,
	-- }
	-- -- Fix Shift + Function key codes. My <S-F1>, <S-F2>, <S-F3> ... are equivalent to <F13>, <F14>, <F15> ...
	-- for fkey_index = 1, 12 do
	--     local effective_keycode = fkey_index + 12
	--     local effective_map = '<F' .. effective_keycode .. '>'
	--     local desired_map = '<S-F' .. fkey_index .. '>'
	--     vim.keymap.set({ 'n', 'v', 'i' }, effective_map, desired_map, opts)
	-- end
	-- ```
	vim.keymap.set({ 'n', 'v', 'i' }, '<S-F' .. fkey_index .. '>', function()
		run_fkey(fkey_index, true)
	end, get_opts('Function key S-' .. fkey_index))
end

-- }}}
