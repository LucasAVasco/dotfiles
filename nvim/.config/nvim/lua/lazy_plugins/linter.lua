--[[ autodoc
	====================================================================================================
	Linter mappings (Plugin)[maps]                                                  *plugin-linter-maps*

	`<leader>Tl` Try to execute the linter on the current buffer.
]]


return {
	{
		'mfussenegger/nvim-lint',

		event = 'BufWrite',

		keys = {
			{'<leader>C', mode = 'n', desc = 'Checkers (linters and formaters)'},
			{ '<leader>Cl', function()
				require('lint').try_lint()
			end, mode = 'n', noremap = true, silent = true, desc = 'Try to execute the linter on the current buffer' },
		},

		config = function()
			local nvim_lint = require('lint')

			nvim_lint.linters_by_ft = {
				-- lua = { 'luacheck' },
			}

			local nvim_lint_group = vim.api.nvim_create_augroup('LinterGroup', { clear = true })

			vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
				group = nvim_lint_group,
				callback = function()
					nvim_lint.try_lint()
				end
			})
		end
	}
}
