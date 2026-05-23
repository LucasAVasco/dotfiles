local autoformat_disabled = false

---Get a list of the formatters configured to the provided buffer
---@param buffer_number number
---@param file_type? string
---@return string[]
local function get_configured_formatters(buffer_number, file_type)
	file_type = file_type or vim.bo[buffer_number].filetype

	local formatter_list = require('conform').formatters_by_ft[file_type]

	if type(formatter_list) == 'function' then
		formatter_list = formatter_list(buffer_number)
	end

	return formatter_list or {}
end

return {
	{
		'stevearc/conform.nvim',

		event = { 'BufWritePre' },

		cmd = {
			'ConformInfo',

			-- My commands (not a `conform.nvim` default)
			'Formatter',
		},

		keys = {
			{
				'gq',
				function()
					require('conform').format()

					-- Exit visual mode
					local mode = vim.api.nvim_get_mode().mode
					if mode == 'v' or mode == 'V' then
						vim.api.nvim_input(vim.api.nvim_replace_termcodes('<ESC>', true, false, true))
					end
				end,
				mode = { 'n', 'x' },
			},
		},

		---@module 'conform'
		---@type conform.setupOpts
		opts = {
			default_format_opts = {
				lsp_format = 'fallback',
			},

			---Format the buffer after save it
			---@param buffer_number number Number of the buffer to format
			---@return conform.FormatOpts format_opts Options passed to the `format()` function
			format_after_save = function(buffer_number)
				-- Auto-format disabled
				if autoformat_disabled then
					return
				end

				-- Auto-format
				return { async = true, lsp_format = 'fallback' }
			end,
		},

		---@param _ string
		---@param opts conform.setupOpts
		config = function(_, opts)
			local settings = require('my_configs.formatter.settings')
			opts.formatters_by_ft = settings.filetype2formatter

			-- Setup
			local conform = require('conform')
			conform.setup(vim.tbl_deep_extend('force', opts, vim.g.conform_opts or {}))

			MYFUNC.create_user_command_from_handler('Formatter', {
				info = 'ConformInfo',

				format = {
					function(...)
						VALIDATE.no_args({ ... })

						conform.format()
					end,

					all = function(...)
						VALIDATE.no_args({ ... })

						for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
							local buffer_options = vim.bo[buffer]
							if vim.api.nvim_buf_is_valid(buffer) and buffer_options.buftype == '' and buffer_options.modifiable then
								conform.format({ bufnr = buffer })
							end
						end
					end,
				},

				auto = {
					function(arg, ...)
						VALIDATE.no_args({ ... })

						if arg == 'enable' then
							autoformat_disabled = false
						elseif arg == 'disable' then
							autoformat_disabled = true
						elseif arg == 'toggle' then
							autoformat_disabled = not autoformat_disabled
						else
							VALIDATE.fail(('error: wrong argument: %s'):format(arg))
						end
					end,
				},
			}, {
				nargs = '+',
				range = true,
				bar = true,
				complete = {
					auto = {
						'enable',
						'disable',
						'toggle',
					},
				},
			})

			-- Automatically installs the formatter with `mason.nvim` {{{

			---Does not install the formatters to these file types
			---@type string[]
			local ft_ignore_installation = {}

			---Convert formatter name from the `conform.nvim` specification to `mason.nvim` specification
			---0 as the name means that there are not a `mason.nvim` equivalent to the formatter
			---@type table<string, string|0>
			local conform2mason = {}

			vim.api.nvim_create_autocmd('BufWritePre', {
				callback = function(arguments)
					-- Buffer information
					local file_type = vim.bo[arguments.buf].filetype

					-- Only installs the formatters once
					if vim.tbl_contains(ft_ignore_installation, file_type) then
						return
					else
						table.insert(ft_ignore_installation, file_type)
					end

					local this_ft_formatter = get_configured_formatters(arguments.buf, file_type)
					local mason_reg = require('mason-registry')

					-- Installation
					for _, conform_name in ipairs(this_ft_formatter) do
						local mason_name = conform2mason[conform_name] or conform_name

						if type(mason_name) ~= 'number' then
							if mason_reg.has_package(mason_name) then
								MYPLUGFUNC.ensure_mason_package_installed(mason_name)
							elseif not vim.tbl_contains(settings.no_notify_if_can_not_install, mason_name) then
								vim.notify(
									('The formatter "%s" can not be installed with `mason.nvim`'):format(mason_name),
									vim.log.levels.WARN
								)
							end
						end
					end
				end,
			})

			-- }}}
		end,
	},
	{
		'johmsalas/text-case.nvim',

		cmd = {
			'Subs',
			'TextCaseOpenTelescope',
			'TextCaseOpenTelescopeLSPChange',
			'TextCaseOpenTelescopeQuickChange',
			'TextCaseStartReplacingCommand',
		},

		keys = {
			'<leader>C',

			{ '<leader>C.', '<CMD>TextCaseOpenTelescope<CR>', desc = 'Change the case with Telescope' },
		},

		opts = {
			prefix = '<leader>C',
		},

		init = function()
			MYPLUGFUNC.load_telescope_extension('textcase', {
				'normal_mode',
				'normal_mode_lsp_change',
				'normal_mode_quick_change',
				'textcase',
				'visual_mode',
			})
		end,

		config = function(_, opts)
			require('textcase').setup(opts)
		end,
	},
}
