local wezterm = require('wezterm')

---@diagnostic disable-next-line: unused-local
wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
	local win_title = ''

	-- Zoom status
	if tab.active_pane.is_zoomed then
		win_title = 'Zoom: ' .. win_title
	end

	-- Title
	win_title = win_title .. tab.active_pane.title

	return win_title
end)
