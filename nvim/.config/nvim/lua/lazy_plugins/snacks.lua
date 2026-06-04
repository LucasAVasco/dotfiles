return {
	{
		'folke/snacks.nvim',
		priority = 15000,
		lazy = false,

		cmd = {
			'Lazygit',
		},

		---@module 'snacks'
		---@type snacks.Config
		opts = {
			image = {
				enabled = MYVAR.not_in_vscode,
				doc = {
					inline = false,
				},
			},
			quickfile = { enabled = true },
			bigfile = { enabled = true },
			lazygit = { enabled = MYVAR.not_in_vscode },
			dashboard = require('lazy_plugins.snacks.dashboard'),
			scratch = {},
			picker = {
				ui_select = true,
			},

			styles = {
				-- Move the image preview to the right of the window. This is useful when the preview is over the code being edited (math
				-- equations, etc.). Try to use the same vertical position as the cursor. If the cursor is too close to the bottom of the
				-- window, it will be moved up
				snacks_image = {
					relative = 'win',
					position = 'float',
					row = function(win)
						local win_id = vim.api.nvim_get_current_win()
						local cursor = vim.api.nvim_win_get_cursor(win_id)
						local screen_cursor = vim.fn.screenpos(win_id, cursor[1], cursor[2] + 1)
						local screen_cursor_row = screen_cursor.row -- Row of the cursor relative to the screen
						screen_cursor_row = screen_cursor_row - 2 -- Remove the buffer line (bufferline.nvim) and drop bar (dropbar.nvim)

						-- Height of the popup
						local popup_height = win.opts.height
						if not popup_height then
							popup_height = vim.api.nvim_win_get_height(win_id)
						elseif type(popup_height) == 'function' then
							popup_height = popup_height(win)
						end
						popup_height = popup_height + 2 -- Add the borders size

						-- Height of the main window (where the cursor is and the image will be displayed)
						local window_height = vim.api.nvim_win_get_height(0)
						if screen_cursor_row + popup_height > window_height then
							return window_height - popup_height
						end

						return screen_cursor_row
					end,

					col = -2,
				},
			},
		},

		config = function(_, opts)
			local snacks = require('snacks')
			snacks.setup(opts)

			vim.api.nvim_create_autocmd('InsertEnter', {
				callback = function()
					snacks.image.doc.hover_close()
				end,
			})

			vim.api.nvim_create_user_command('Colorize', function(args)
				snacks.terminal.colorize()
			end, {})

			-- LazyGit
			if MYVAR.not_in_vscode then
				vim.api.nvim_create_user_command('Lazygit', function()
					snacks.lazygit.open()
				end, {})
			end

			-- Scratch
			vim.api.nvim_create_user_command('Scratch', function()
				snacks.scratch()
			end, { desc = 'Toggle scratch buffer' })

			vim.api.nvim_create_user_command('ScratchSelect', function()
				snacks.scratch.select()
			end, { desc = 'Select scratch buffer' })

			---Debug object
			---@class my.debug.object
			---@field print fun(...)
			---@field backtrace fun()
			_G.vim.debug = {
				print = snacks.debug.inspect,
				backtrace = snacks.debug.backtrace,
			}
			vim.print = snacks.debug.inspect
		end,
	},
}
