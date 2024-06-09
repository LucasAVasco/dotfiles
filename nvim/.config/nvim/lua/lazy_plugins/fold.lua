--- Sets the current folding level
-- Values preceded with a '+' or '-' will be added or subtracted from the current fold level. Otherwise, the
-- value will be set as the new fold level.
-- @param new_level String of the new fold level, or the increase or decrease of the current fold level
local function set_fold_level(new_level)
	local level = tonumber(vim.w.ufo_fold_level or 0)
	local first_char = new_level:sub(1, 1)

	-- Plus and Minus operations
	if first_char == '+' then
		level = level + tonumber(new_level:sub(2))

	elseif first_char == '-' then
		level = level - tonumber(new_level:sub(2))

	-- Absolute set operation
	else
		level = tonumber(new_level)
	end

	-- Does not allow negative values
	level = level < 0 and 0 or level

	-- Applies the new value
	require('ufo').closeFoldsWith(level)
	vim.w.ufo_fold_level = level
end


--- Custom virtual text in the fold
-- Returns the list of elements of the custom text to be shown in the closed fold
-- @param virtual_text {text, highlightGroup}[] List of elements of the first line of the fold
-- @param start_line number Start line of the fold
-- @param end_line number End line of the fold
-- @param width number Width that the text should fit
-- @param truncate func(string, number): string Crops the text to fit the width
-- @param fold_context table Context of the fold
-- @return {text, highlightGroup}[] List of elements of the custom text to be shown in the closed fold
local function fold_text_handler(virtual_text, start_line, end_line, width, truncate, fold_context)
	local suffix = ('   󰦸 %d '):format(end_line - start_line)
	local suffix_width = vim.fn.strdisplaywidth(suffix)
	local new_virt_text = virtual_text
	local available_width = width - suffix_width  -- width of the text to be added to the new virtual text

	for index, chunk in ipairs(virtual_text) do
		-- chunk[1] is the text
		-- chunk[2] is the highlight group

		local chunk_width = vim.fn.strdisplaywidth(chunk[1])

		available_width = available_width - chunk_width

		-- Available width is not enough to add the next chunk
		if available_width <= 0 then
			new_virt_text = {unpack(virtual_text, 1, index)}  -- Copies the virtual text up to the current index (last)
			new_virt_text[#new_virt_text][1] = truncate(chunk[1], chunk_width + available_width)  -- Crops the last item to fit the width
			break
		end
	end

	-- Adds the remaining elements to the new virtual text and returns
	table.insert(new_virt_text, {suffix, 'MoreMsg'})
	return new_virt_text
end


return {
	{
		'kevinhwang91/nvim-ufo',
		dependencies = {
			'kevinhwang91/promise-async'
		},

		-- Chances the default installation to use my fork of 'nvim-ufo'
		-- TODO: remove this when the fork is merged
		url = 'https://github.com/LucasAVasco/nvim-ufo',
		branch = 'markerAndMergeProviders',

		config = function()
			vim.o.foldenable = true
			vim.o.foldmethod = 'manual'
			vim.o.foldcolumn = 'auto:9'
			vim.o.foldlevel = 99 -- UFO requires a large value
			vim.o.foldlevelstart = 99
			vim.g.ufo_auto_preview = true

			local ufo = require('ufo')

			-- #region Some useful functions

			--- Returns a function that runs 'func' and after this, it will run peek the preview
			-- @param func function that will be run before peek
			-- @return Decorated function
			local function decorator_apply_peek(func)
				return function()
					func()

					-- Only peek if 'ufo_auto_preview' is 'true'
					if vim.g.ufo_auto_preview then
						local win_id = ufo.peekFoldedLinesUnderCursor()

						-- If there is a preview window
						if win_id then
							local buf_nr = vim.api.nvim_win_get_buf(win_id)

							-- Remaps key that go to insert mode to trace to the previewed code (<CR>) before it
							local insert_maps = {'i', 'I', 'a', 'A', 'o', 'O', 'gI', 'gi', 'c', 'cc', 'C', 's', 'S'}
							for _, key in ipairs(insert_maps) do
								vim.keymap.set('n', key, '<CR>' .. key, {buffer = buf_nr, remap = true, silent = true})
							end
						end
					end
				end
			end

			--- Function that only closes the markers, but opens the rest
			local function close_only_markers()
				ufo.openFoldsExceptKinds({'ufo_marker'})
			end

			-- #endregion


			-- #region Mappings

			local default_options = myfunc.decorator_create_options_table({ noremap = true, silent = true })

			myplugfunc.set_keymap_name('<leader>z', 'Folding mappings', {'n'})
			vim.keymap.set('n', 'zR', ufo.openAllFolds, default_options('Open all folds'))  -- UFO requires to remap the `zR` and `zM` keys
			vim.keymap.set('n', 'zM', ufo.closeAllFolds, default_options('Close all folds'))
			vim.keymap.set('n', '<leader>zm', close_only_markers, default_options('Close only markers folds'))
			vim.keymap.set('n', '<leader>zp', ufo.peekFoldedLinesUnderCursor, default_options('Peek current fold'))

			vim.keymap.set('n', '<leader>ztp', function()  -- Toggle auto preview
				vim.g.ufo_auto_preview = not vim.g.ufo_auto_preview
			end, default_options('Toggle auto preview'))

			-- Movement mappings
			local default_modes = { 'n', 'v', 'i' }

			vim.keymap.set(default_modes, '<A-m>', close_only_markers, default_options('Close only markers folds'))
			vim.keymap.set(default_modes, '<A-k>', decorator_apply_peek(ufo.goPreviousClosedFold), default_options('Previous fold'))
			vim.keymap.set(default_modes, '<A-j>', decorator_apply_peek(ufo.goNextClosedFold), default_options('Next fold'))

			vim.keymap.set(default_modes, '<A-H>', myfunc.decorator_call_function(set_fold_level, { '-1' }), default_options('Fold level -1'))
			vim.keymap.set(default_modes, '<A-L>', myfunc.decorator_call_function(set_fold_level, { '+1' }), default_options('Fold level +1'))

			vim.keymap.set(default_modes, '<A-h>', function()  -- Go to previous start fold and closes it
				ufo.goPreviousStartFold()
				vim.cmd('silent! normal zc')  -- Silent because this command can show a error message if not found a fold
			end, default_options('Close previous fold'))

			vim.keymap.set(default_modes, '<A-l>', function()  -- Go into the next fold (opens it)
				vim.cmd('silent! normal zo')  -- Silent because this command can show a error message if not found a fold
			end, default_options('Open current fold'))

			-- #endregion


			-- #region User commands

			-- User command to set the fold level
			vim.api.nvim_create_user_command('SetFoldLevel', function(arguments)
				set_fold_level(arguments.fargs[1])
			end, {
				nargs = 1,
				complete = myfunc.create_complete_function({
					'+0', '+1', '+2', '+3', '+4', '+5', '+6', '+7', '+8', '+9', '-0', '-1', '-2', '-3', '-4', '-5', '-6', '-7', '-8', '-9',
					'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
				})
			})

			-- User command to configure the auto preview
			vim.api.nvim_create_user_command('SetFoldAutoPreview', function(arguments)
				if arguments.fargs[1] == 'y' then
					vim.g.ufo_auto_preview = true

				elseif arguments.fargs[1] == 'n' then
					vim.g.ufo_auto_preview = false

				elseif arguments.fargs[1] == 'toggle' then
					vim.g.ufo_auto_preview = not vim.g.ufo_auto_preview

				else
					print('Argument 1 must be either "y", "n" or "toggle"')
				end
			end, {
				nargs = 1,
				complete = myfunc.create_complete_function({ 'y', 'n', 'toggle' })
			})

			-- #endregion


			-- UFO setup
			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return ufo.mergeProviders({ 'marker', 'treesitter' })
				end,

				close_fold_kinds_for_ft = {
					default = { 'ufo_marker' }  -- Closes the markers after open a buffer
				},

				fold_virt_text_handler = fold_text_handler,  -- Custom virtual text in the fold

				-- If you need the `get_fold_virt_text` function in `fold_context` of the 'fold_virt_text_handler',
				-- you need to set it to `true`
				enable_get_fold_virt_text = false,

				preview = {
					mappings = {
						scrollE = '<A-e>',
						scrollY = '<A-y>',
					}
				},
			})
		end
	}
}
