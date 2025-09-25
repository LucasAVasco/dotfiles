---@meta

---@module 'dap'

---@alias my_config.DAP.adapter dap.Adapter Configuration of a debugger adapter.

---@class my_config.DAP.debugee Configuration of a debugee.
---@field name string Name of the configuration.
---@field type string Name of the debugger adapter.
---@field request? 'attach' | 'launch' Default to 'launch'
---@field program? string The program to debug. Default is '${file}'

---@alias my_config.DAP.debugee_file table<string, my_config.DAP.debugee[]> Maps each file type to its debugee configuration.
