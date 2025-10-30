#!/bin/lua

-- Set the current back light level. Has support to gamma correction.

if #arg < 1 or arg[1] == "-h" or arg[1] == "--help" then
	print([[
Set the current back light level. Has support to gamma correction.

USAGE
	set_backlight <value>
		Value can be: <value>, <value>%, +<value>, -<value>, +<value>%, -<value>%. The + and - values are added to the current value. The %
		will be treated as a percentage with gamma correction
]])
	os.exit(#arg < 1 and 1 or 0)
end

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
local function get_backlight_status()
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

---Set the back light level.
---
---Absolute value. Just configure the value directly in the device (without gamma correction).
---@param status BackLightStatus
---@param value integer Value between 1 and maximum.
local function set_backlight_abs(status, value)
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
local function set_backlight_percent(status, percent)
	local current = percent / 100
	current = current ^ 2.2 -- Gamma correction

	current = current * status.maximum
	set_backlight_abs(status, current)
end

---Add a value to the current back light level. Does not apply gamma correction.
---@param status BackLightStatus
---@param value integer Value between 1 and maximum.
local function add_backlight_abs(status, value)
	set_backlight_abs(status, status.current + value)
end

---Add a value to the current back light level. Apply gamma correction.
---@param status BackLightStatus
---@param percent number Value between 0 and 100.
local function add_backlight_percent(status, percent)
	local current = status.current / status.maximum
	current = current ^ (1 / 2.2) -- Gamma correction

	current = current + percent / 100
	current = current ^ 2.2 -- Gamma correction
	set_backlight_abs(status, current * status.maximum)
end

---Set the back light level.
---@param status BackLightStatus
---@param value string
local function set_backlight(status, value)
	local set = true -- Set the value instead of add
	local percent = false -- Value is a percent instead of absolute

	local first_char = value:sub(1, 1)
	if first_char == "+" or first_char == "-" then
		set = false
	end

	local last_char = value:sub(-1)
	if last_char == "%" then
		percent = true
		value = value:sub(1, -2) -- Removes the %
	end

	local value_num = tonumber(value) or 1

	if set then
		if percent then
			print("set_backlight_percent(status, " .. value_num .. ")")
			set_backlight_percent(status, value_num)
		else
			print("set_backlight_abs(status, " .. value_num .. ")")
			set_backlight_abs(status, value_num)
		end
	else
		if percent then
			print("add_backlight_percent(status, " .. value_num .. ")")
			add_backlight_percent(status, value_num)
		else
			print("add_backlight_abs(status, " .. value_num .. ")")
			add_backlight_abs(status, value_num)
		end
	end
end

-- Get the back light value
local value = arg[1]
if value == nil then
	os.exit(1)
end

-- Updates the back light
set_backlight(get_backlight_status(), arg[1])
