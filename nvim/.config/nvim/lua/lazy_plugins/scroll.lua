return {
	{
		'petertriho/nvim-scrollbar',
		lazy = false,

		keys = {
			{
				'<leader>mj',
				function()
					require('scrollbar').jump()
				end,
				mode = 'n',
			},
			{
				'<leader>mp',
				function()
					require('scrollbar').peek()
				end,
				mode = 'n',
			},
			{
				'<leader>mg',
				function()
					require('scrollbar').glance()
				end,
				mode = 'n',
			},
		},

		opts = {
			exclude = {
				filetypes = MYVAR.utilities_ft,
			},

			providers = {
				gitsigns = true,
			},

			scrollbar = {
				preset = 'intellij',
			},

			minimap = {
				enabled = true,
				preset = 'zed',
			},
		},
	},
}
