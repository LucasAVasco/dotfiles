require("lib.help").handle_help_message([[
Runs a shell command an tries to adapt the output to output as JSON lines.

The supported commands are available at the `./adapter/` directory.

USAGE
run [-h | --help]
	Show this help message.

run <command> [arguments...]
	Run the given command with the given arguments and applies the adapter to it.
]])

local uv = require("luv")

---@return string?
local function main()
	-- Must provide a command
	if #arg < 1 then
		return "Missing command"
	end

	-- Arguments to pass to the runner
	local args = {}
	for i = 2, #arg do
		table.insert(args, arg[i])
	end

	-- Command to execute
	local command = arg[1]

	---Runner of the command
	local ok, adapter_function = pcall(require, "./adapter/" .. command)
	if not ok then
		return "Error loading adapter function: " .. adapter_function
	end

	if type(adapter_function) ~= "function" then
		return "Unknown adapter type (must be a function): " .. adapter_function
	end

	-- Gets the new command and arguments
	command, args = adapter_function(command, args)

	-- Runs the command
	---@cast adapter_function fun(command: string, args: string[]): string, string[]
	local handler
	handler = uv.spawn(command, { args = args, stdio = { 0, 1, 2 } }, function(code, _)
		os.exit(code)

		handler:close()
	end)

	uv.run()
end

local err = main()
if err then
	print(err)
	os.exit(1)
end
