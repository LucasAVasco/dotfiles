local diagnostic_type2icon = {
	error = '',
	warning = '',
	hint = '',
}


return {
	{
		'akinsho/bufferline.nvim',
		version = '*',

		dependencies = {
			'nvim-tree/nvim-web-devicons'
		},

		opts = {
			options = {
				separator_style = 'slant',

				hover = {
					enabled = true,
					reveal = { 'close' },
					delay = 0,
				},

				toggle_hidden_on_enter = true,  -- Opens a hidden buffer when entering it

				-- Diagnostics
				diagnostics = 'nvim_lsp',

				---Get the diagnostic text to be placed in the buffer tab
				---@param total number Number of diagnostics
				---@param level string Name of the diagnostic type
				---@param diagnostics_number table<string, number> Each diagnostic and its count
				---@param diagnostic_data table<string, any> Data related to the diagnostic
				---@return string indicator
				---@diagnostic disable-next-line: unused-local
				diagnostics_indicator = function(total, level, diagnostics_number, diagnostic_data)
					local result = ''
					for _, diagnostic_type in ipairs({'error', 'warning', 'hint'}) do
						if diagnostics_number[diagnostic_type] then
							result = result .. diagnostic_type2icon[diagnostic_type] .. diagnostics_number[diagnostic_type]
						end
					end

					return result
				end,

				-- Offset the buffer line when some applications take part of the screen
				offsets = {
					{ filetype = 'NvimTree' },
				}
			},
		},

		config = function(_, opts)
			local bufferline = require('bufferline')
			local bufferline_groups = require('bufferline.groups')
			local bufferline_state = require('bufferline.state')

			vim.opt.mousemoveevent = true  -- Required to enable 'hover'

			-- Number before the buffer title
			opts.options.numbers = function(number_opts)
				local jump_index = 1

				-- Get the index of the buffer in the tabs. If you want to use only the visible buffers, replace the
				-- `bufferline_state.components` by `bufferline_state.visible_components`
				local components = bufferline_state.components
				for i=1,#components do
					if components[i].id == number_opts.id then
						jump_index = i
						break
					end
				end

				return jump_index .. number_opts.lower(number_opts.id)
			end

			-- Automatic groups
			local docs_filetypes = { 'tex', 'texmf', 'texinfo', 'markdown', 'asciidoc', 'rst', 'text', 'help', 'help_ru' }

			local conf_filetypes = {
				'conf', 'config', 'configini', 'json', 'jsonc', 'json5', 'jsonnet', 'yaml', 'toml',

				-- Specif to applications
				'i3config', 'inittab'
			}

			opts.options.groups = {
				items = {
					bufferline_groups.builtin.pinned:with({ icon = "󰐃" }),
					bufferline_groups.builtin.ungrouped,
					{
						name = 'Conf',
						icon = '',

						---Filter that defines if a buffer is belongs to a configuration file
						---@param buffer table Data related to buffer
						---@return boolean belongs_to_conf_group
						matcher = function(buffer)
							local filetype = vim.bo[buffer.id].filetype
							return vim.fn.index(conf_filetypes, filetype) >= 0
						end
					},
					{
						name = 'Docs',
						icon = '',

						---Filter that defines if a buffer belongs to a documentation file
						---@param buffer table Data related to buffer
						---@return boolean belongs_to_docs_group
						matcher = function(buffer)
							local filetype = vim.bo[buffer.id].filetype
							return vim.fn.index(docs_filetypes, filetype) >= 0
						end
					},
					{
						name = 'Log',
						icon = '',

						---Filter that defines if a buffer belongs to a logging file
						---@param buffer table Data related to buffer
						---@return boolean belongs_to_log_group
						matcher = function(buffer)
							return buffer.name:match('%.log')
						end
					}
				}
			}

			bufferline.setup(opts)

			-- Key maps
			local get_map_opts = MYFUNC.decorator_create_options_table({
				remap=false,
				silent=true,
			})

			MYPLUGFUNC.set_keymap_name('<leader>B', 'Buffer keymaps')
			vim.keymap.set('n', '<leader>Bg', bufferline.pick, get_map_opts('Pick a buffer and go to it'))
			vim.keymap.set('n', '<leader>Bp', '<CMD>BufferLineTogglePin<CR>', get_map_opts('Pin/unpin the current buffer'))
			vim.keymap.set('n', '<leader>BC', bufferline.close_others, get_map_opts('Close other buffers'))

			vim.keymap.set('n', '<leader>Bc', function()
				for buffer_id=1,vim.fn.bufnr('$') do
					for _, buffer in ipairs(vim.fn.getbufinfo(buffer_id)) do
						-- The current buffer will be set to hidden when the user switches to another buffer. When the user opens multiple
						-- files, these buffers are not hidden. This command will not close buffers until the user accesses it at least once
						if buffer.listed == 1 and buffer.hidden == 1 then
							bufferline.unpin_and_close(buffer_id)
						end
					end
				end
			end, get_map_opts('Close all hidden buffers'))

			vim.keymap.set('n', '<A-w>', bufferline.unpin_and_close, get_map_opts('Close the current buffer'))

			-- Key maps to jump to a buffer
			for i=1, 9 do
				vim.keymap.set('n', '<A-' .. i .. '>', MYFUNC.decorator_call_function(bufferline.go_to, {i, true}),
					get_map_opts('Go to buffer ' .. i ))
			end
			vim.keymap.set('n', '<A-0>', MYFUNC.decorator_call_function(bufferline.go_to, {-1, true}), get_map_opts('Go to last buffer'))
			vim.keymap.set('n', '<A-[>', MYFUNC.decorator_call_function(bufferline.cycle, {-1}), get_map_opts('Go to previous buffer'))
			vim.keymap.set('n', '<A-]>', MYFUNC.decorator_call_function(bufferline.cycle, {1}), get_map_opts('Go to next buffer'))
		end
	},
	{
		'nvim-lualine/lualine.nvim',

		dependencies = {
			'nvim-tree/nvim-web-devicons'
		},

		opts = {
			options = {
				section_separators = { left = '', right = '' },
				component_separators = { left = '', right = '' },

				ignore_focus = {'Telescope', 'NvimTree'},
			},

			sections = {
				-- At left
				lualine_a = {
					{ 'mode', separator = { left = ' '} },
				},

				-- At right
				lualine_x = {
					{ '%B', icon = '󰛘' },  -- Hex value of the character over the cursor
					'encoding', 'fileformat', 'filetype'
				},

				lualine_z = {
					{ 'location', separator = { right = ' '} },
				},
			}
		},

		config = function(_, opts)
			require('lualine').setup(opts)
		end
	}
}
