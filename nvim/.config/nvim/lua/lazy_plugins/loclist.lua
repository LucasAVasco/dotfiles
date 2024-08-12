--[[ autodoc
	====================================================================================================
	Loclist and quickfix mappings (Plugin)[maps]                                   *plugin-loclist-maps*

	`<leader>Td` Open diagnostics with Trouble

	Movement~

	`<leader>Tgg`   Go to first trouble item
	`<leader>TG`    Go to last trouble item
]]

-- Key maps to jump between loclist and quickfix entries {{{

local function load_trouble()
	local trouble = require('trouble')

	-- Default open mode
	if not trouble.is_open() then
		trouble.open('diagnostics')
	end
end

---Function key mappings to jump between the lists items
---@type MyFunctionKeysMappings
local diagnostics_fkeys = {
	shift = { '<CMD>lprev<CR>', '<CMD>cprev<CR>', load_trouble },
	normal = { '<CMD>lnext<CR>', '<CMD>cnext<CR>', load_trouble },
}

local key_options = MYFUNC.decorator_create_options_table({
	noremap = true,
	silent = true,
})

vim.keymap.set('n', '[l', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 1, true), key_options('Previous loclist item'))
vim.keymap.set('n', ']l', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 1), key_options('Next loclist item'))
vim.keymap.set('n', '[q', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 2, true), key_options('Previous quickfix item'))
vim.keymap.set('n', ']q', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 2), key_options('Next quickfix item'))

-- }}}

return {
	{
		'folke/trouble.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },

		keys = {
			{ '<leader>Td', '<CMD>Trouble diagnostics toggle<CR>', desc = 'Open the diagnostics' },
			{ '<leader>Tl', '<CMD>lclose<CR><CMD>Trouble loclist<CR>', desc = 'Open the loclist in Trouble' },
			{ '<leader>Tq', '<CMD>qclose<CR><CMD>Trouble quickfix<CR>', desc = 'Open the quickfix in Trouble' },
			{ '[T', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 3, true), desc = 'Previous Trouble item' },
			{ ']T', MYFUNC.decorator_set_fkey_mappings(diagnostics_fkeys, 3), desc = 'Next Trouble item' },
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

		init = function ()
			MYPLUGFUNC.set_keymap_name('<leader>T', 'Trouble (list plugin)')
		end,

		config = function(_, opts)
			-- Basic configuration
			local trouble = require('trouble')
			trouble.setup(opts)

			---Decorator that focuses on Trouble before run the function and jump after run it
			---First, it checks if there is an open Trouble window. If there is, it focuses on it, run the function and jump to
			---the selected position
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

			local modes = {'n', 'v'}
			vim.keymap.set(modes, '<leader>Tgg', decorator_focus_trouble_and_jump(trouble.first),
				key_options('Go to first trouble diagnostics'))
			vim.keymap.set(modes, '<leader>TG', decorator_focus_trouble_and_jump(trouble.last),
				key_options('Go to last trouble diagnostics'))

			---Go to next or previous position in Trouble and jump to it
			---@param next boolean If `true`, go to next position, otherwise go to previous
			local function next_position(next)
				local trouble = require('trouble')

				-- Default open mode
				if not trouble.is_open() then
					trouble.open('diagnostics')
				end

				-- Does not jump if can not open the mode
				if trouble.is_open() then
					if next then
						trouble.next()
					else
						trouble.prev()
					end

					trouble.jump_only()
				end
			end

			-- Overrides the function key mappings that loads `trouble.nvim` by the ones that jumps to a `trouble.nvim` entry
			diagnostics_fkeys.shift[3] = MYFUNC.decorator_call_function(next_position, {false})
			diagnostics_fkeys.normal[3] = MYFUNC.decorator_call_function(next_position, {true})

			MYFUNC.set_fkey_mappings(diagnostics_fkeys, nil, nil, true)  -- Reload after the changes
		end
	}
}
