-- Key map to close the quickfix list

---@type vim.keymap.set.Opts
local opts = {
	buffer = true,
	noremap = true,
	silent = true,
	desc = 'Close quickfix list',
}

vim.keymap.set('n', '<A-q>', ':cclose<CR>', opts)
vim.keymap.set('n', '<A-S-q>', ':cclose<CR>', opts)
