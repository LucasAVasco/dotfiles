---@module 'my_configs.DAP.types'

---@type my_config.DAP.adapter
return {
	id = 'lldb',
	type = 'server',
	port = '${port}',
	executable = {
		command = 'codelldb',
		args = { '--port', '${port}' },
	},
}
