---@class myconfig.DAP.settings
local Config = {
	---Maps each file type to its default debugger adapters.
	---@type table<string, string[]>
	file_type2adapter = {
		go = { 'delve' },
		python = { 'debugpy' },
		c = { 'gdb', 'lldb' },
		cpp = { 'gdb', 'lldb' },
	},
}

return Config
