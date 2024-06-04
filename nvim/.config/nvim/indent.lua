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
-- @param prefix Prefix of the group name
-- @param indent_colors Colors of the indentation highlight groups
-- @return Names of the indentation highlight groups
local function create_highlight_groups(indent_colors, namespace_id)
	-- Default values
	prefix = prefix or ''
	namespace_id = namespace_id or 0

	-- Name of the indentation highlight groups
	local indent_groups = {}

	-- Gets the name of the indentation highlight and adds them to the 'indent_groups' table (one group per 'indent_colors')
	for index, color in ipairs(indent_colors) do
		local group_name = 'IndentGroup' .. tostring(index)
		table.insert(indent_groups, group_name)
	end

	-- Creates the highlight groups
	for index, color in ipairs(indent_colors) do
		vim.api.nvim_set_hl(0, indent_groups[index], {
			fg=color,
		})
	end

	return indent_groups
end


--- Apply the matches to the indentation syntax groups
-- Apply the indentation highlight groups to the current window. Repeat the highlight groups *repeats* times. Example: if *repeats* is 1,
-- apply the matches only one time. Example: If the *indent_groups* is {'IndentGroup1', 'IndentGroup2'} and *repeats* is 1, the first
-- indentation level will be highlighted with the 'IndentGroup1' and the second indentation level will be highlighted with the 'IndentGroup2'.
-- If *repeats* is 2, the first will be highlighted with the 'IndentGroup1' and the second with the 'IndentGroup2' and the third with the
-- 'IndentGroup1' and the fourth with the 'IndentGroup2'.
-- Only apply to the current window. It is a limitation of `vim.fn.matchadd()`
-- @param indent_groups Names of the indentation highlight groups
-- @param repeats Number of times to repeat the highlight groups in the next indentation level
-- @return Table of the matches
local function apply_matches(indent_groups, repeats)
	-- Applies the matches to the indentation syntax groups
	local indent_size = vim.opt.tabstop:get()  -- Number of spaces of a indentation level
	local indent_index = 1                     -- Level of the current indentation been applied

	local matches = {}
	for index = 1, repeats do
		for _, group_name in ipairs(indent_groups) do
			-- Applies the match to space indentation (soft tabs)
			local start_column = (indent_index-1) * indent_size + 1  -- Start column of the current indentation (not used by hard tabs)
			local match = vim.fn.matchadd(group_name, string.format([[^\s*\zs\%%%sc%s]], start_column, string.rep(' ', indent_size)))
			table.insert(matches, match)

			-- Applies the match to tab indentation (hard tabs)
			match = vim.fn.matchadd(group_name, string.format([[^\s*\zs\%%%sc\t]], indent_index, string.rep(' ', indent_size)))
			table.insert(matches, match)

			-- Next indentation level
			indent_index = indent_index + 1
		end
	end

	return matches
end


--- Like apply_matches, but checks if the user can apply the matches to the current window.
-- Only apply the matches if the user can apply the highlight groups to the current window.
-- If applying new matches, the previous ones will be removed
-- @param indent_groups Names of the indentation highlight groups
-- @param repeats Number of times to repeat the highlight groups in the next indentation level
local function update_window_matches(indent_groups, repeats)
	local window_id = vim.api.nvim_get_current_win()

	-- Checks if the user can apply the matches to the current window. If not, aborts
	if myfunc.user_can_change_appearance(window_id) then

		-- Removes the previous matches
		if vim.w.indent_hl_matches then
			for _, match in ipairs(vim.w.indent_hl_matches) do
				vim.fn.matchdelete(match)
			end
		end

		-- New matches
		vim.w.indent_hl_matches = apply_matches(indent_groups, repeats)
	end
end

-- #endregion


-- #region Setup

local indent_groups = create_highlight_groups(indent_colors)

local indent_hl_augroup = vim.api.nvim_create_augroup('IndentHlGroup', { clear = true })

-- Automatically updates the matches when the buffer is loaded in the window
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufNewFile'}, {
	group = indent_hl_augroup, callback = function(event)
		update_window_matches(indent_groups, repeat_times)
	end
})


-- Updates the matches when the 'tabstop' option or the color scheme is change
vim.api.nvim_create_autocmd({'ColorScheme', 'OptionSet'}, {
	group = indent_augroupe, callback = function(arguments)
		-- Need to recreate the matches related to white spaces if the tabstop option is changed because this option changes the number
		-- of spaces in an indentation level, so the matches need to be updated to correspond to the new number of spaces
		if arguments.match == 'tabstop' then
			update_window_matches(indent_groups, repeat_times)

		-- highlight groups are removed when the color scheme is changed. Need to recreate the groups and matches
		elseif arguments.event == 'ColorScheme'  then
			indent_groups = create_highlight_groups(indent_colors)
			update_window_matches(indent_groups, repeat_times)
		end
	end
})

-- #endregion
