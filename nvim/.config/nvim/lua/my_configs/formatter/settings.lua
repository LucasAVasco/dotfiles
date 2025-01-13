---@class myconfig.formatter.settings
---@field filetype2formatter table<string, string[]> Map each file-type to a list of available code-formatters.
local Config = {
	filetype2formatter = {
		lua = { 'stylua' },
	},
}

return Config