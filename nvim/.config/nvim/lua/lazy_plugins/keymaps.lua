return {
	{
		'folke/which-key.nvim',
		event = 'VeryLazy',

		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,

		opts = {
			-- #region Apearance

			icons = {
				breadcrumb = '󰋇', -- Separator for each element of the keybind combo
				separator = '=', -- Separator between each key and its description
				group = ' ', -- Indicator for a group
			},

			window = {
				border = 'rounded', -- Same as `nvim_open_win`
				position = 'bottom',
			},

			-- #endregion
		},

		config = function(_, opts)
			local wk = require('which-key')

			wk.setup(opts)

			-- Now can set keymap names
			MYVAR.is_wichkey_loaded = true
			MYPLUGFUNC.start_keymap_register()

			-- Some descriptions for keymaps
			MYPLUGFUNC.set_keymap_name('<leader>', 'My keymaps')
		end
	}
}
