--[[ autodoc
	====================================================================================================
	Linter mappings (Plugin)[maps]                                                  *plugin-linter-maps*

	`<leader>Tl` Try to execute the linter on the current buffer.
]]

return {
	{
		'mfussenegger/nvim-lint',

		event = 'BufWrite',

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>C', 'Checkers (linters and testers)')
		end,

		cmd = {
			'Lint',
		},

		config = function()
			local nvim_lint = require('lint')

			nvim_lint.linters_by_ft = {
				['*'] = { 'cspell' },
				-- lua = { 'luacheck' },
			}

			local function lint_current_file()
				-- File type specific linters
				nvim_lint.try_lint()

				-- Linters applied to all files
				local linters_all_filetypes = nvim_lint.linters_by_ft['*']
				if linters_all_filetypes then
					nvim_lint.try_lint(linters_all_filetypes)
				end
			end

			---Dismiss diagnostics to a specific buffer
			---@param buffer_number? integer Number of the buffer to dismiss diagnostics. Nil to dismiss all diagnostics of all buffers.
			local function dismiss_lint_diagnostics(buffer_number)
				for _, filetype in pairs(nvim_lint.linters_by_ft) do
					for _, linter in ipairs(filetype) do
						local namespace = nvim_lint.get_namespace(linter)
						vim.diagnostic.reset(namespace, buffer_number)
					end
				end
			end

			local auto_lint_enabled = true

			-- User commands
			vim.api.nvim_create_user_command('Lint', function(args)
				if args.nargs == 0 then
					vim.notify('You must provide an argument!', vim.log.levels.ERROR)
					return
				end

				local handler = MYFUNC.get_fargs_handler(args.fargs, {
					['lint'] = lint_current_file,
					['clear'] = function()
						dismiss_lint_diagnostics(0)
					end,
					['clear all'] = dismiss_lint_diagnostics,
					['autolint enable'] = function()
						auto_lint_enabled = true
					end,
					['autolint disable'] = function()
						auto_lint_enabled = false
					end,
				})

				if not handler then
					vim.notify(('Unknown sub-command: "%s"'):format(args.args), vim.log.levels.ERROR)
					return
				end

				handler()
			end, {
				desc = 'Linter management command',

				nargs = '+',

				complete = MYFUNC.create_complete_function({
					'lint',

					clear = {
						'all',
					},

					autolint = {
						'enable',
						'disable',
					},
				}),
			})

			-- Auto commands
			local nvim_lint_group = vim.api.nvim_create_augroup('LinterGroup', { clear = true })

			vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
				group = nvim_lint_group,
				callback = function()
					if not auto_lint_enabled then
						return
					end

					lint_current_file()
				end,
			})
		end,
	},
}
