#!/bin/lua

-- Set the current back light level. Has support to gamma correction.

local backlight = require("backlight")

if #arg < 1 or arg[1] == "-h" or arg[1] == "--help" then
	print([[
Set the current back light level. Has support to gamma correction.

Usage:
	backlight set <value>

Arguments:
	value
		Backlight value can be: <value>, <value>%, +<value>, -<value>, +<value>%, -<value>%. The + and - values are added to the current
		value. The % will be treated as a percentage with gamma correction
]])
	os.exit(#arg < 1 and 1 or 0)
end

-- Get the back light value
local value = arg[1]
if value == nil then
	os.exit(1)
end

-- Current back light status
local status = backlight.get_current_backlight_status()

local set = true -- Set the value instead of adding to it
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
		backlight.set_backlight_percent(status, value_num)
	else
		backlight.set_backlight_abs(status, value_num)
	end
else
	if percent then
		backlight.add_backlight_percent(status, value_num)
	else
		backlight.add_backlight_abs(status, value_num)
	end
end
