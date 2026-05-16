#!/bin/lua

-- Get the current back light level

local backlight = require("backlight")

if arg[1] == "-h" or arg[1] == "--help" then
	print([[
Get the current back light level information. Show if the monitor is external, the maximum back light level and the current back light level
(absolute value and percentage with gamma correction)

Usage:
	backlight get [-j|--json]

Flags:
	-j, --json    Output in JSON format
]])
	os.exit(#arg < 1 and 1 or 0)
end

local status = backlight.get_current_backlight_status()
local percent = backlight.get_backlight_percent(status)

-- JSON
if arg[1] == "-j" or arg[1] == "--json" then
	print(([[{
  "is_external": %s,
  "maximum": %s,
  "current": %s,
  "percent": %s
}]]):format(status.is_external, status.maximum, status.current, percent))
	return
end

-- Non JSON
print(([[
is_external: %s
maximum: %s
current: %s
percent: %s
]]):format(status.is_external, status.maximum, status.current, percent))
