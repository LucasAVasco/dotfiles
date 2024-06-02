return {
	{
		'folke/which-key.nvim',
		event = 'VeryLazy',

		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 500
		end,

		opts = {
			plugins = {
				marks = true,
				registers = true,

				spelling = {
					enabled = true, -- 'z=' will use WhichKey
					suggestions = 50,
				},

				presets = {
					operators = true,
					motions = true,
					text_objects = true,
					windows = true,
					nav = true,
					z = true,
					g = true,
				},
			},

			-- #region Behavior

			ignore_missing = false, -- Show mapping even if it has not a description

			show_help = true,  -- Help message in command line
			show_keys = true,  -- Current keys in command line
			triggers = 'auto',  -- Automatically shows WhichKey for all defined keymaps

			triggers_nowait = {
				-- marks
				'`',
				"'",
				'g`',
				"g'",

				-- registers
				'"',
				'<c-r>',

				-- spelling
				'z=',
			},

			-- #endregion

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

		config = function(plugin, opts)
			wk = require('which-key')

			wk.setup(opts)

			-- Now can set keymap names
			is_wichkey_loaded = true
			myplugfunc.start_keymap_register()

			-- Some descriptions for keymaps
			myplugfunc.set_keymap_name('<leader>', 'My keymaps')
		end
	}
}
