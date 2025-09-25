---@module 'my_configs.DAP.types'

---@type my_config.DAP.adapter
return {
	id = 'delve',
	port = '${port}',
	type = 'server',
	executable = {
		command = 'dlv',
		args = { 'dap', '--listen', '127.0.0.1:${port}' },
	},
}
