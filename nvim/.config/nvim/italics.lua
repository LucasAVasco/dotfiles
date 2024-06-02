-- Applies italics to all comments
local function apply_italics()
	vim.cmd('highlight Comment cterm=italic gui=italic')
end

apply_italics()


-- Applies italics to all comments after loading a colorscheme
vim.api.nvim_create_autocmd({"ColorScheme"}, {
	pattern = '*', callback = apply_italics
})
