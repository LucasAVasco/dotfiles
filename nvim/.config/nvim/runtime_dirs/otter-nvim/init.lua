-- Activate `otter.nvim` after Neovim startup
vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		require('otter').activate()
	end,
})
