local M = {}

---Run a command and returns the output.
---@param cmd string The command to run in a shell.
---@return string
local function exec(cmd)
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	f:close()
	return s
end

---Check if the monitor is external.
---@return boolean `true` if the monitor is external.
local function monitor_is_external()
	-- TODO(LucasAVasco): support to multiple monitors

	-- Fallback option. Check if /sys/class/backlight/<name> exists
	if exec("ls /sys/class/backlight/") == "" then
		return true
	end

	return false
end

---@class BackLightStatus
---@field is_external boolean
---@field maximum integer
---@field current integer

---Get the current back light status.
---@return BackLightStatus
function M.get_current_backlight_status()
	---@type BackLightStatus
	local status = {
		is_external = monitor_is_external(),
		maximum = 1,
		current = 1,
	}

	if status.is_external then
		local out = exec("ddcutil getvcp 10")
		local matches = { out:match("current value =%s*(%d+), max value =%s*(%d+)") }

		if #matches > 1 then
			status.current = tonumber(matches[1]) or 1
			status.maximum = tonumber(matches[2]) or 1
		end
	else
		status.current = tonumber(exec("brightnessctl get")) or 1
		status.maximum = tonumber(exec("brightnessctl max")) or 1
	end

	return status
end

---Get the current back light level in percentage with gamma correction.
---@param status BackLightStatus
---@return number
function M.get_backlight_percent(status)
	local percent = status.current / status.maximum

	-- Gamma correction
	percent = percent ^ (1 / 2.2)
	return percent * 100
end

---Set the back light level.
---
---Absolute value. Just configure the value directly in the device (without gamma correction).
---@param status BackLightStatus
---@param value integer Value between 1 and maximum.
function M.set_backlight_abs(status, value)
	-- Rounding
	value = math.floor(value)

	-- Bounds
	if value < 1 then
		value = 1
	elseif value > status.maximum then
		value = status.maximum
	elseif tostring(value) == "-nan" or tostring(value) == "nan" then
		value = 1
	end

	-- Sets the value
	if monitor_is_external() then
		exec("ddcutil setvcp 10 " .. value)
	else
		exec("brightnessctl set " .. value)
	end

	-- Updates the status
	status.current = value
end

---Set the back light level. Apply gamma correction.
---@param status BackLightStatus
---@param percent number Value between 0 and 100.
function M.set_backlight_percent(status, percent)
	local current = percent / 100
	current = current ^ 2.2 -- Gamma correction

	current = current * status.maximum
	M.set_backlight_abs(status, current)
end

---Add a value to the current back light level. Does not apply gamma correction.
---@param status BackLightStatus
---@param value integer Value between 1 and maximum.
function M.add_backlight_abs(status, value)
	M.set_backlight_abs(status, status.current + value)
end

---Add a value to the current back light level. Apply gamma correction.
---@param status BackLightStatus
---@param percent number Value between 0 and 100.
function M.add_backlight_percent(status, percent)
	local current = status.current / status.maximum
	current = current ^ (1 / 2.2) -- Gamma correction

	current = current + percent / 100
	current = current ^ 2.2 -- Gamma correction
	M.set_backlight_abs(status, current * status.maximum)
end

return M
