-- Colors used in each indentation level. Appears in the same order as the indentation levels. The first one will be used to the
-- first indentation level, the second one to the second, and so on.
local indent_colors = {
	'#118110',
	'#004488',
	'#999900',
	'#119999',
	'#990099',
	'#555aaa'
}

-- Number of times to repeat the colors in the next indentation level. This script will apply all the colors of *indent_colors*'. The
-- first repeat will re-apply all the indentation colors of *indent_colors* in the next indentation level. Example: if *indent_colors* is
-- { '#118110', '#004488' } and *repeats* is 2, the indentation levels will have colors: '#118110', '#004488', '#118110', '#004488',
-- '#118110', '#004488', in this order (left to right)
local repeat_times = 10


-- #region Functions

--- Create the indentation highlight groups
---@param indent_fg_colors table Colors of the indentation highlight groups
---@return table list_hl_croups Names of the indentation highlight groups
local function create_highlight_groups(indent_fg_colors, namespace_id)
	-- Default values
	namespace_id = namespace_id or 0

	-- Name of the indentation highlight groups
	local indent_groups = {}

	-- Gets the name of the indentation highlight and adds them to the 'indent_groups' table (one group per 'indent_colors')
	for index, _ in ipairs(indent_fg_colors) do
		local group_name = 'IndentGroup' .. tostring(index)
		table.insert(indent_groups, group_name)
	end

	-- Creates the highlight groups
	for index, color in ipairs(indent_fg_colors) do
		vim.api.nvim_set_hl(namespace_id, indent_groups[index], {
			fg=color,
		})
	end

	return indent_groups
end


--- Apply the matches to the indentation syntax groups
--- Apply the indentation highlight groups to the current window. Repeat the highlight groups *repeats* times. Example: If the
--- *indent_groups* is {'IndentGroup1', 'IndentGroup2'} and *repeats* is 1, the first indentation level will be highlighted with the
--- 'IndentGroup1' and the second indentation level will be highlighted with the 'IndentGroup2'. If *repeats* is 2, the first will be
--- highlighted with the 'IndentGroup1' and the second with the 'IndentGroup2' and the third with the 'IndentGroup1' and the fourth with the
--- 'IndentGroup2'.
---@param indent_groups table Names of the indentation highlight groups
---@param repeats number Number of times to repeat the highlight groups in the next indentation level
---@param window_id number ID of the window to apply the highlights
---@return table matches_list List of the created matches
local function apply_matches(indent_groups, repeats, window_id)
	-- Applies the matches to the indentation syntax groups
	local indent_size = vim.bo.tabstop  -- Number of spaces of a indentation level

	local indent_index = 1
	local priority = 15  -- Matches priority (default value is 10)
	local match_config = {
		window = window_id,
	}

	local matches = {}
	for _ = 1, repeats do
		for _, group_name in ipairs(indent_groups) do
			-- Applies the match to space indentation (soft tabs)
			local start_column = (indent_index-1) * indent_size + 1  -- Start column of the current indentation (not used by hard tabs)
			local match = vim.fn.matchadd(group_name,
				string.format([[^\s*\zs\%%%sc%s]], start_column, string.rep(' ', indent_size)),
				priority, -1, match_config
			)
			table.insert(matches, match)

			-- Applies the match to tab indentation (hard tabs)
			match = vim.fn.matchadd(group_name, string.format([[^\s*\zs\%%%sc\t]], indent_index), priority, -1, match_config)
			table.insert(matches, match)

			-- Next indentation level
			indent_index = indent_index + 1
		end
	end

	return matches
end


--- Like apply_matches, but checks if the user can apply the matches to the current window.
--- Only apply the matches if the user can apply the highlight groups to the current window.
--- Does not applies the matches more that one time
---@param indent_groups table Names of the indentation highlight groups
---@param repeats number Number of times to repeat the highlight groups in the next indentation level
---@param window_id number ID of the window to apply the highlights
local function update_window_matches(indent_groups, repeats, window_id)
	-- Checks if the user can apply the matches to the current window. If not, aborts
	if not MYFUNC.user_can_change_appearance(window_id) then
		return
	end

	-- Only applies the matches one time. The matches are not removed when the user changes the color schemes
	if vim.w[window_id].__indent_hl_matches_applied == true then
		return
	end

	vim.w[window_id].__indent_hl_matches_applied = true

	-- Matches creation
	apply_matches(indent_groups, repeats, window_id)
end

-- #endregion


-- #region Setup

local indent_groups = create_highlight_groups(indent_colors)

local indent_hl_augroup = vim.api.nvim_create_augroup('IndentHlAugroup', { clear = true })

-- Automatically updates the matches when the buffer is loaded in the window
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufNewFile'}, {
	group = indent_hl_augroup, callback = function(arguments)
		local window_id = MYFUNC.get_window_by_buffer(arguments.buf)

		update_window_matches(indent_groups, repeat_times, window_id)
	end
})


-- Updates the matches when the 'tabstop' option or the color scheme is change
vim.api.nvim_create_autocmd({'ColorScheme', 'OptionSet'}, {
	group = indent_hl_augroup, callback = function(arguments)
		-- Need to recreate the matches related to white spaces if the `tabstop` option is changed because this option changes the number of
		-- spaces in an indentation level, so the matches need to be updated to correspond to the new number of spaces
		if arguments.event == 'OptionSet' and arguments.match == 'tabstop' then
			local window_id = MYFUNC.get_window_by_buffer(arguments.buf)
			update_window_matches(indent_groups, repeat_times, window_id)

		-- highlight groups are removed when the color scheme changes. Need to recreate the groups and matches
		elseif arguments.event == 'ColorScheme' then
			-- The highlight groups are removed after change the color scheme. Need to recreate them. The matches are not removed after
			-- change the color scheme. No need to recreate it
			indent_groups = create_highlight_groups(indent_colors)
		end
	end
})

-- #endregion
