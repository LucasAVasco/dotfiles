-- Disables the default style used in markdown files (configured at /usr/share/nvim/runtime/ftplugin/markdown.vim)
vim.g.markdown_recommended_style = 0

MYFUNC.call_if_before_editor_config(function()
	vim.bo.expandtab = true
	vim.bo.tabstop = 2
end)
