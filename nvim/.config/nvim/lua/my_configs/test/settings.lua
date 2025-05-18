---@class my_config.test.settings
---@field default_adapters table<string, string[]> Relates a file type to its default Neotest adapters (base file name at './adapter/')
return {
	default_adapters = {
		go = { 'golang' },
	},
}
