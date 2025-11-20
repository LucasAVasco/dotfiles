local wezterm = require('wezterm')

wezterm.on('open-uri', function(window, pane, uri)
	-- Current working directory
	local cwd = pane:get_current_working_dir()

	if cwd ~= nil then
		cwd = cwd.file_path
	end

	-- Opens the URI
	window:perform_action(
		wezterm.action.SpawnCommandInNewWindow({
			args = { 'default_open', uri },
			cwd = cwd,
		}),
		pane
	)

	return false
end)
