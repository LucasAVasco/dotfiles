return {
	{
		'mistweaverco/kulala.nvim',
		ft = 'http',

		opts = {
			display_mode = 'float',
		},

		init = function()
			vim.filetype.add({
				extension = {
					['http'] = 'http',
				},
			})
		end,

		config = function(_, opts)
			local kulala = require('kulala')
			kulala.setup(opts)

			MYPLUGFUNC.set_keymap_name('<leader>R', 'Request mappings')

			---Set key maps on the request file
			---@param buffer_nun integer
			local function load_keymaps(buffer_nun)
				if vim.bo[buffer_nun].filetype ~= 'http' then
					return
				end

				local keymap_opts = MYFUNC.decorator_create_options_table({
					buffer = buffer_nun,
					remap = false,
					silent = true,
				})

				vim.keymap.set('n', '<leader>Rr', function()
					kulala.run()
				end, keymap_opts('Exequte the current request'))

				vim.keymap.set('n', '[r', function()
					kulala.jump_prev()
				end, keymap_opts('Jump to previous request'))

				vim.keymap.set('n', ']r', function()
					kulala.next_prev()
				end, keymap_opts('Jump to next request'))

				vim.keymap.set('n', '<leader>Ri', function()
					kulala.inspect()
				end, keymap_opts('Inspect request'))

				vim.keymap.set('n', '<leader>Rv', function()
					kulala.toggle_view()
				end, keymap_opts('Toggle request view'))

				vim.keymap.set('n', '<leader>Ry', function()
					kulala.copy()
				end, keymap_opts('Copy current request as a CURL command to the clipboard'))

				vim.keymap.set('n', '<leader>Rp', function()
					kulala.from_curl()
				end, keymap_opts('Past current request from a CURL command at the clipboard'))
			end

			-- Setup 'http' buffers key maps
			load_keymaps(0)

			vim.api.nvim_create_autocmd('BufRead', {
				pattern = '*.http',
				callback = function(args)
					load_keymaps(args.buf)
				end,
			})
		end,
	},
}
