---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
local Config = {
	on_exit = function(code, signal, _)
		vim.notify('LSP server qmlls exited with code ' .. code .. ' and signal ' .. signal, vim.log.levels.INFO, { title = 'LSP' })

		-- `qmlls` usually crashes several times when editing files, so we restart it after a short delay
		vim.defer_fn(function()
			vim.schedule(function()
				vim.notify('Restarting qmlls', vim.log.levels.INFO, { title = 'LSP' })
				vim.cmd.LspStart({ args = { 'qmlls' } })
			end)
		end, 500)
	end,
}

return Config
