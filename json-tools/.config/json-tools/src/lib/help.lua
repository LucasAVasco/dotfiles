local M = {}

---Show a help message if the user provided the `--help` or `-h` flags and exit the program.
---@param message string
function M.handle_help_message(message)
	local first_arg = arg[1]

	if first_arg == "--help" or first_arg == "-h" then
		print(message)
		os.exit(0)
	end
end

return M
