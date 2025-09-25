---@module 'my_configs.DAP.types'

---@type my_config.DAP.adapter
return {
	id = 'gdb',
	type = 'executable',
	command = 'gdb',
	args = { '--quiet', '--interpreter=dap' },
}
