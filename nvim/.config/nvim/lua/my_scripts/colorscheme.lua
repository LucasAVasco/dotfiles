--[[
	Applies the last user-selected color scheme

	This script needs to be run after the color scheme plugin is loaded

	It also creates an automatic command to save the color scheme name whenever the user changes it
]]

local file_path = MYPATHS.data .. '/last_colorsheme' -- File to save the current color scheme name

-- Auto-command to save the color scheme name after the user select it
vim.api.nvim_create_autocmd('ColorScheme', {
	callback = function(arguments)
		local file = io.open(file_path, 'w')
		if file ~= nil then
			file:write(arguments.match)
			file:close()
		end
	end,
})

-- Load the last selected color-scheme
local colorscheme = ''
local file = io.open(file_path, 'r')
if file ~= nil then
	colorscheme = file:read('*a')
	file:close()
end

-- Default color scheme
if colorscheme == '' and vim.env.ALLOW_EXTERNAL_SOFTWARE == 'y' then
	colorscheme = 'kanagawa'
end

-- Color scheme update
if colorscheme ~= '' then
	local success, result = pcall(vim.cmd.colorscheme, colorscheme)

	if not success then
		vim.notify(('Can not load the color scheme: %s. Result: %s'):format(colorscheme, vim.inspect(result)), vim.log.levels.ERROR)
	end
end
