--[[
	Applies the last user-selected color scheme

	This script needs to be run after the color scheme plugin is loaded

	It also creates an automatic command to save the color scheme name whenever the user changes it
]]


local file_path = MYPATHS.data .. '/last_colorsheme'  -- File to save the current color scheme name


-- Load the last selected color-scheme
local file = io.open(file_path, 'r')
if file ~= nil then
	local colorscheme = file:read('*a')
	vim.cmd.colorscheme(colorscheme)
	file:close()
end


-- Auto-command to save the color scheme name after the user select it
vim.api.nvim_create_autocmd('ColorScheme', {
	callback = function(arguments)
		file = io.open(file_path, 'w')
		if file ~= nil then
			file:write(arguments.match)
			file:close()
		end
	end
})
