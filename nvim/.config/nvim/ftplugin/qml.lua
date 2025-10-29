MYFUNC.call_if_before_editor_config(function()
	vim.bo.expandtab = true
	vim.bo.tabstop = 4
end)

-- Automatically restart 'qmlls' when the execute the ':edit' command:. As a consequence, it will also be restarted when a new file is
-- opened
vim.defer_fn(function()
	vim.schedule(function()
		vim.notify('Restarting qmlls', vim.log.levels.INFO, { title = 'LSP' })
		vim.cmd.LspStop({ args = { 'qmlls' } })
	end)
end, 500)
