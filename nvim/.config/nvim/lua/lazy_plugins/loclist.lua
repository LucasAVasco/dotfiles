--[[ autodoc
	====================================================================================================
	Loclist and quickfix mappings (Plugin)[maps]                                   *plugin-loclist-maps*

	`<leader>Td` Open diagnostics with Trouble

	Movement~

	`<leader>Tgg`   Go to first trouble diagnostics
	`<leader>TG`    Go to last trouble diagnostics
	`<F3>`          Go to previous trouble diagnostics
	`<S-F2>`          Go to next trouble diagnostics
]]


MYPLUGFUNC.set_keymap_name('<leader>T', 'Trouble (list plugin)')


return {
	{
		'folke/trouble.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },

		keys = {
			{ '<leader>Td', '<CMD>Trouble diagnostics toggle<CR>', desc = 'Open the diagnostics' },
			{ '<leader>Tl', '<CMD>lclose<CR><CMD>Trouble loclist<CR>', desc = 'Open the loclist in Trouble' },
			{ '<leader>Tq', '<CMD>qclose<CR><CMD>Trouble quickfix<CR>', desc = 'Open the quickfix in Trouble' },
		},

		cmd = 'Trouble',

		opts = {
			--Behavior
			auto_close = true,
			auto_refresh = true,
			auto_preview = false,  -- If `true`, may cause some bugs with `nvim-tree.lua`

			throttle = {
				preview = {ms = 0},
			},

			-- Appearance
			icons = {
				indent = {
					last = '╰╴'
				}
			}
		},

		config = function(_, opts)
			-- Basic configuration
			local trouble = require('trouble')
			trouble.setup(opts)

			-- Keymaps
			local key_options = MYFUNC.decorator_create_options_table({
				noremap = true,
				silent = true,
			})

			--- Decorator that focuses on Trouble before run the function and jump after run it
			--- First, it checks if there is an open Trouble window. If there is, it focuses on it, run the function and jump to
			--- the selected position
			---@param func fun() Function that will be run after get focus on Trouble and before the jump
			---@return fun() decorated_function
			local function decorator_focus_trouble_and_jump(func)
				return function()
					if trouble.is_open() then
						trouble.focus()
						func()
						trouble.jump_only()
					end
				end
			end

			--- Go to next or previous position in Trouble (manually call the preview)
			---@param next boolean If `true`, go to next position, otherwise go to previous
			local function next_position(next)
				if trouble.is_open() then
					local current_win_id = vim.api.nvim_get_current_win()
					local view = trouble.focus()

					-- Movement
					if next then
						trouble.next()
					else
						trouble.prev()
					end

					if not view.opts.auto_preview then
						-- Need to call twice to remove the old preview before set the new one
						if current_win_id == vim.api.nvim_get_current_win() then
							trouble.preview()
						end

						-- Set the new preview
						trouble.preview()
					end
				end
			end

			local modes = {'n', 'v'}
			vim.keymap.set(modes, '<leader>Tgg', decorator_focus_trouble_and_jump(trouble.first),
				key_options('Go to first trouble diagnostics'))
			vim.keymap.set(modes, '<leader>TG', decorator_focus_trouble_and_jump(trouble.last),
				key_options('Go to last trouble diagnostics'))

			modes = {'n', 'v', 'i'}
			vim.keymap.set(modes, '<F2>', MYFUNC.decorator_call_function(next_position, {true}),
			key_options('Go to next trouble diagnostics'))

			vim.keymap.set(modes, MYFUNC.get_F_key('S', 2), MYFUNC.decorator_call_function(next_position, {false}),
			key_options('Go to previous trouble diagnostics'))
		end
	}
}
