local wezterm = require('wezterm')
local colors = require('wez-colors')

---@diagnostic disable-next-line: unused-local
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
	---Index text
	---@type string
	local index

	if tab.tab_index >= 5 then
		index = ' F' .. tab.tab_index - 4 .. ' '
	else
		index = ' ' .. tab.tab_index + 1 .. ' '
	end

	---Title text
	---@type string
	local title = tab.tab_title -- Title manually set by user

	if #title == 0 then
		title = tab.active_pane.title
	end

	if #title == 0 then
		title = '?' -- Fallback value
	end

	local title_max_size = max_width - (#index + 6)
	if #title > title_max_size then
		title = title:sub(0, title_max_size - 1) .. '…'
	end

	title = ' ' .. title .. ' '

	-- Colors

	local index_bg = colors.color_window_status_inactive
	if tab.is_active then
		index_bg = colors.color_window_status_current
	end

	local index_fg = colors.color_window_number_fg
	local tab_bg = colors.color_window_name_bg
	local tab_bar_bg = colors.tab_bar_bg

	return {
		{ Background = { Color = tab_bar_bg } },
		{ Foreground = { Color = index_bg } },
		{ Text = '' },
		{ Foreground = { Color = index_fg } },
		{ Background = { Color = index_bg } },
		{ Text = index },
		{ Background = { Color = tab_bg } },
		{ Foreground = { Color = index_bg } },
		{ Text = '' },
		{ Background = { Color = tab_bg } },
		{ Foreground = { Color = index_bg } },
		{ Text = title },
		{ Foreground = { Color = tab_bg } },
		{ Background = { Color = tab_bar_bg } },
		{ Text = ' ' },
	}
end)
