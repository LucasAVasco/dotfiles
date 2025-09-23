local wezterm = require('wezterm')

-- Event to copy the output of the last non-empty output.
wezterm.on('copy-last-output', function(_, pane)
	-- All output semantic zones
	local zones = pane:get_semantic_zones('Output')
	if #zones == 0 then
		return
	end

	-- Text of last non-empty semantic zone
	local text
	for i = #zones, 1, -1 do
		text = pane:get_text_from_semantic_zone(zones[i])
		if text ~= nil and text ~= '' then
			break
		end
	end

	if text == nil then
		return nil
	end

	io.popen('clip-copy --stdin', 'w'):write(text):close()
end)
