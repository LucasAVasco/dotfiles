---@class my_scripts.validate
---Functions to validate arguments. You can use this to check the arguments of a function or user command
VALIDATE = {}

---Fail with a message
---@param message any
function VALIDATE.fail(message)
	error(message, 2)
end

---Fail with a message. The `VALIDATE.fail()` function can not be used inside the other functions of this module because its stack level is
---configured to the caller function (it would inform that the functions of this module are the cause of the error). This function has a
---bigger stack level to compensate this issue
---@param message any
local function fail(message)
	error(message, 3)
end

---Validate that the number of arguments is between min and max
---@param args any[]
---@param min integer
---@param max integer
function VALIDATE.number_of_args(args, min, max)
	if #args < min or #args > max then
		fail(('Expected %d (min) to %d (max) arguments, got %d'):format(min, max, #args))
	end
end

---Validate that the number of arguments is zero
---@param args any[]
function VALIDATE.no_args(args)
	if #args > 0 then
		fail(('Expected 0 arguments, got %d'):format(#args))
	end
end

---Validate that arg is one of the options
---@param arg any
---@param options any[]
function VALIDATE.one_of(arg, options)
	if not vim.tbl_contains(options, arg) then
		fail(('Expected one of %s, got %s'):format(table.concat(options, ', '), arg))
	end
end
