---Translate a text from one language to another.
---@param src_lang? string
---@param dest_lang string
---@param text string
---@return string result, string? error
local function translate(src_lang, dest_lang, text)
	---@type string[]
	local cmd = { 'trans', '-brief' }

	if src_lang then
		table.insert(cmd, '--from')
		table.insert(cmd, src_lang)
	end

	MYFUNC.array_concat(cmd, { '--to', dest_lang, text })

	local result = vim.system(cmd, {
		detach = false,
	}):wait()

	if result.code ~= 0 then
		return '', 'Error code: ' .. tostring(result.code) .. ' Stderr: ' .. result.stderr
	end

	return result.stdout
end

---Translate the current or last selected text.
---@param buffer_number integer Number of the buffer.
---@param src_lang? string
---@param dest_lang string
---@return string? translated_text, string? error
local function translate_last_selection(buffer_number, src_lang, dest_lang)
	local lines = MYFUNC.get_last_selection_lines(buffer_number)
	if not lines then
		return 'There is not a last selection'
	end

	local translated, err = translate(src_lang, dest_lang, table.concat(lines, ' '))
	if err then
		return nil, "Error translating: '" .. err
	end

	return translated
end

---Replace the last selection of a buffer by some text
---@param buffer_number integer
---@param lines string[]
---@return string? error
local function replace_last_selection(buffer_number, lines)
	local selected_region = MYFUNC.get_last_selection(buffer_number)

	if not selected_region then
		return 'There is not a last selection to this buffer'
	end

	-- Replaces the original text by its translation
	vim.api.nvim_buf_set_text(
		buffer_number,
		selected_region.open[1] - 1,
		selected_region.open[2],
		selected_region.close[1] - 1,
		selected_region.close[2],
		lines
	)
end

---Translate the current or last selected text and replaces it by its translation.
---@param buffer_number integer Number of the buffer.
---@param src_lang? string
---@param dest_lang string
---@return string? error
local function translate_and_replace_last_selection(buffer_number, src_lang, dest_lang)
	local translated, err = translate_last_selection(buffer_number, src_lang, dest_lang)
	if err then
		return 'Error translation last selection: ' .. err
	end

	if not translated then
		return
	end

	err = replace_last_selection(buffer_number, MYFUNC.str_split(translated, '\n'))
	if err then
		return 'Error replacing last selection: ' .. err
	end
end

vim.api.nvim_create_user_command('Translate', function(args)
	---@type string?
	local err

	if #args.fargs == 0 then
		err = translate_and_replace_last_selection(0, nil, 'pt-br')
	elseif #args.fargs == 1 then
		err = translate_and_replace_last_selection(0, nil, args.fargs[1])
	elseif #args.fargs == 2 then
		err = translate_and_replace_last_selection(0, args.fargs[1], args.fargs[2])
	end

	if err then
		vim.notify('Error translating and replacing selected text: ' .. err, vim.log.levels.ERROR)
	end
end, {
	range = true,
	nargs = '*',
})

---Rewrites the text.
---
---Converts a text from original language to intermediate one, and goes back from intermediate language to original one.
---@param intermediate_lang string
---@param original_lang string
---@param text string
---@return string rewritten_text, string? Error
local function rewrite_text(intermediate_lang, original_lang, text)
	local translated, err = translate(intermediate_lang, original_lang, text)
	if err then
		return 'Error translation from original to intermediate languages: ' .. err
	end

	if not translated then
		return ''
	end

	translated, err = translate(intermediate_lang, original_lang, translated)
	if err then
		return 'Error translation last selection: ' .. err
	end

	return translated
end

---Rewrites the last selected area
---@param buffer_number integer Number of the buffer.
---@param intermediate_lang string
---@param original_lang string
---@return string? error
local function rewrite_last_selection(buffer_number, intermediate_lang, original_lang)
	local lines = MYFUNC.get_last_selection_lines(buffer_number)
	if not lines then
		return 'There is not a last selection'
	end

	local translated, err = rewrite_text(intermediate_lang, original_lang, table.concat(lines, ' '))
	if err then
		return 'Error rewriting text: ' .. err
	end

	if not translated then
		return
	end

	err = replace_last_selection(buffer_number, MYFUNC.str_split(translated, '\n'))
	if err then
		return 'Error replacing last selection: ' .. err
	end
end

vim.api.nvim_create_user_command('Rewrite', function(args)
	rewrite_last_selection(0, 'pt-br', args.fargs[1] or 'en')
end, {
	nargs = '?',
	range = true,
})
