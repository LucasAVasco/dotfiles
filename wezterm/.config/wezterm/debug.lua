local wezterm = require('wezterm')

---@class DegugUtil Debug utility available in all WezTerm scripts. Use 'ShowDebugOverlay' to show all debug logs
---@field info fun(...: any) Logs info message
---@field warn fun(...: any) Logs warning message
---@field error fun(...: any) Logs error message
DEBUG = {}
DEBUG.info = wezterm.log_info
DEBUG.warn = wezterm.log_warn
DEBUG.error = wezterm.log_error

---Notify the user
---@param title? string
---@param ... string
function DEBUG.notify(title, ...)
	local msg = table.concat({ ... }, ' ')
	title = title or 'WezTerm'

	wezterm.background_child_process({ 'notify-send', title, msg })
end

---Get the string representation of a value
---@param ... any
---@return string
function DEBUG.inspect(...)
	return wezterm.to_string(...)
end
