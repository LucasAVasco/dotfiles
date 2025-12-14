local M = {}

local enabled = false

---Set the visibility of the tab bar if only one tab is open.
---
---If multiple tabs are open, the tab bar is always visible.
---@param window any
---@param enable boolean
function M.set_visibility_single_tab(window, enable)
	-- Only enables the tab bar once
	if enabled == enable then
		return
	end
	enabled = enable

	-- Overrides the tab bar configuration
	local overrides = window:get_config_overrides() or {}
	overrides.hide_tab_bar_if_only_one_tab = not enable
	window:set_config_overrides(overrides)
end

return M
