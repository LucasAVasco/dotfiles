local M = {}

--- Run a command and return its output.
---@param cmd string The command to run in a shell.
---@return string
local function exec(cmd)
	local f = assert(io.popen(cmd, "r"), "Failed to execute: " .. cmd)
	local output = f:read("*a")
	local ok, _, code = f:close()

	assert(output ~= nil, "Failed to read command output: " .. cmd)
	assert(ok, ("Command failed (exit code %s): %s"):format(code or "unknown", cmd))

	return output
end

--- Check if the monitor is external.
---@return boolean `true` if the monitor is external.
local function monitor_is_external()
	-- TODO(LucasAVasco): support multiple monitors

	-- Check whether a backlight interface exists.
	local output = exec("ls -A /sys/class/backlight/")

	return output == ""
end

---@class BackLightStatus
---@field is_external boolean
---@field maximum integer
---@field current integer

--- Get the current backlight status.
---@return BackLightStatus
function M.get_current_backlight_status()
	---@type BackLightStatus
	local status = {
		is_external = monitor_is_external(),
		maximum = 1,
		current = 1,
	}

	if status.is_external then
		local output = exec("ddcutil getvcp 10")

		local current, maximum = output:match("current value%s*=%s*(%d+),%s*max value%s*=%s*(%d+)")

		if current and maximum then
			status.current = tonumber(current) or 1
			status.maximum = tonumber(maximum) or 1
		end
	else
		status.current = tonumber(exec("brightnessctl get")) or 1
		status.maximum = tonumber(exec("brightnessctl max")) or 1
	end

	-- Ensure valid values.
	if status.maximum <= 0 then
		status.maximum = 1
	end

	status.current = math.max(1, math.min(status.current, status.maximum))

	return status
end

--- Get the current backlight level in percentage with gamma correction.
---@param status BackLightStatus
---@return number
function M.get_backlight_percent(status)
	if status.maximum <= 0 then
		return 0
	end

	local percent = status.current / status.maximum

	-- Gamma correction.
	percent = percent ^ (1 / 2.2)

	return percent * 100
end

--- Set the backlight level.
---
--- Absolute value. Configures the hardware directly (without gamma correction).
---@param status BackLightStatus
---@param value number Value between 1 and maximum.
function M.set_backlight_abs(status, value)
	-- Handle invalid values.
	if value ~= value or value == math.huge or value == -math.huge then
		value = 1
	else
		value = math.floor(value)
	end

	-- Bounds.
	value = math.max(1, math.min(value, status.maximum))

	-- Set the hardware value.
	if status.is_external then
		exec("ddcutil setvcp 10 " .. value)
	else
		exec("brightnessctl set " .. value)
	end

	-- Update the status.
	status.current = value
end

--- Set the backlight level with gamma correction.
---@param status BackLightStatus
---@param percent number Value between 0 and 100.
function M.set_backlight_percent(status, percent)
	-- Handle invalid values.
	if percent ~= percent or percent == math.huge or percent == -math.huge then
		percent = 0
	end

	-- Bounds.
	percent = math.max(0, math.min(percent, 100))

	local current = percent / 100
	current = current ^ 2.2

	current = current * status.maximum

	M.set_backlight_abs(status, current)
end

--- Add a value to the current backlight level.
--- Does not apply gamma correction.
---@param status BackLightStatus
---@param value number Value to add.
function M.add_backlight_abs(status, value)
	M.set_backlight_abs(status, status.current + value)
end

--- Add a value to the current backlight level with gamma correction.
---@param status BackLightStatus
---@param percent number Percentage to add.
function M.add_backlight_percent(status, percent)
	if percent ~= percent or percent == math.huge or percent == -math.huge then
		percent = 0
	end

	if status.maximum <= 0 then
		return
	end

	local current = status.current / status.maximum

	-- Convert to perceived brightness.
	current = current ^ (1 / 2.2)

	-- Apply the increment.
	current = current + percent / 100

	-- Clamp perceived brightness.
	current = math.max(0, math.min(current, 1))

	-- Convert back to hardware brightness.
	current = current ^ 2.2
	current = current * status.maximum

	M.set_backlight_abs(status, current)
end

return M
