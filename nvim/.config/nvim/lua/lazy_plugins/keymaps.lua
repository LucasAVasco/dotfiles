---@type { [string]: number }
local whichkey_maps_with_delay = {} -- Key maps with specific delay before showing `which-key`. Delay in milliseconds

-- Key maps that immediately shows `which-key` (without delay)
for _, key in ipairs({ "'", '"', '`', 'z=' }) do
	whichkey_maps_with_delay[key] = 0
end

return {
	{
		'folke/which-key.nvim',
		event = 'VeryLazy',

		dependencies = {
			'echasnovski/mini.icons',
		},

		opts = {
			delay = function(context)
				return whichkey_maps_with_delay[context.keys] or 300 -- Delay before showing `which-key`. Milliseconds
			end,

			-- #region Appearance

			icons = {
				breadcrumb = '󰋇', -- Separator for each element of the key bind combo
				separator = '=', -- Separator between each key and its description
				group = ' ', -- Group indicator
			},

			win = {
				border = 'rounded',
			},

			-- #endregion
		},

		config = function(_, opts)
			local whichkey = require('which-key')

			whichkey.setup(opts)

			-- Can set key maps name after `which-key` setup
			MYPLUGFUNC.load_pending_keymaps()

			-- Key maps that show the `which-key` pop up
			local get_keymap_opts = MYFUNC.decorator_create_options_table({ remap = false, silent = true })
			MYPLUGFUNC.set_keymap_name('<leader>?', 'show `which-key` window', { 'n', 'x' })
			vim.keymap.set({ 'n', 'x' }, '<leader>?g', whichkey.show, get_keymap_opts('Show all key maps'))
			vim.keymap.set(
				{ 'n', 'x' },
				'<leader>?l',
				MYFUNC.decorator_call_function(whichkey.show, { { global = false } }),
				get_keymap_opts('show local key maps')
			)

			-- Some key maps descriptions
			MYPLUGFUNC.set_keymap_name('<leader>', 'My keymaps')
		end,
	},
}
