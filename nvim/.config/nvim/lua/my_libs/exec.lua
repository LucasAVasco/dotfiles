local M = {}

---@class Process
---@field stdout string[] Buffer with standard output text.
---@field stderr string[] Buffer with standard error text.
---@field opts vim.SystemOpts Options passed to |vim.system()|
---@field on_exit fun(out: vim.SystemCompleted) Function to call when the process exits.
---@field sys_obj vim.SystemObj Object returned by |vim.system()|
---@field _cmd_str string String representing the command. Can not be called. Used for notifications.
M.System = {}
M.System.__index = M.System
setmetatable(M.System, M.System)

---Create a new Process object.
---@param args string[]
---@param opts? vim.SystemOpts
---@param on_exit? fun(out: vim.SystemCompleted)
---@return Process
function M.System:new(args, opts, on_exit)
	---@type Process | {}
	local new_obj = {
		stdout = {},
		stderr = {},
		opts = opts or {},
		on_exit = on_exit or function() end,
		_cmd_str = '`' .. table.concat(args, ' ') .. '`',
	}
	setmetatable(new_obj, self)

	new_obj:_configure_opts()
	new_obj:_configure_on_exit()

	new_obj.sys_obj = vim.system(args, new_obj.opts, new_obj.on_exit)

	return new_obj
end

---Appends text to a buffer.
---@param buffer string[] Buffer to append to.
---@param text? string Text to append (if provided).
local function append_received_text(buffer, text)
	if text then
		table.insert(buffer, text)
	end
end

---Displays a error notification to the user.
---@param err? string Message to show (if provided).
---@param opts? table Same value as in |vim.notify()|
local function notify_error(err, opts)
	if err then
		vim.notify('error receiving: ' .. err, vim.log.levels.ERROR, opts)
	end
end

---Configure the 'opts' table.
function M.System:_configure_opts()
	-- Standard output

	local callback = self.opts.stdout or function() end

	local notification_config = {
		title = 'Stdout of ' .. self._cmd_str,
	}

	self.opts.stdout = function(err, data)
		append_received_text(self.stdout, data)
		notify_error(err, notification_config)
		callback(err, data)
	end

	-- Standard error

	callback = self.opts.stderr or function() end

	notification_config = {
		title = 'Stderr of ' .. self._cmd_str,
	}

	self.opts.stderr = function(err, data)
		append_received_text(self.stderr, data)
		notify_error(err, notification_config)
		callback(err, data)
	end
end

---Show a notification with the buffer content if it is not empty.
---@param buffer string[]
---@param opts? table
local function notify_if_buffer_not_empty(buffer, opts)
	if #buffer == 0 then
		return
	end

	if #buffer == 1 and buffer[1] == '' then
		return
	end

	vim.notify(table.concat(buffer, '\n'), vim.log.levels.INFO, opts)
end

---Configures the 'on_exit' function.
function M.System:_configure_on_exit()
	local user_callback = self.on_exit

	---@param out vim.SystemCompleted
	self.on_exit = function(out)
		-- Appends received text
		append_received_text(self.stdout, out.stdout)
		append_received_text(self.stderr, out.stderr)

		-- Error code
		table.insert(self.stdout, 'Exit code: ' .. out.code)

		-- Shows the outputs
		notify_if_buffer_not_empty(self.stdout, {
			title = '[exit] Stdout of ' .. self._cmd_str,
		})

		notify_if_buffer_not_empty(self.stderr, {
			title = '[exit] Stderr of ' .. self._cmd_str,
		})

		-- Calls the old function
		user_callback(out)
	end
end

return M
