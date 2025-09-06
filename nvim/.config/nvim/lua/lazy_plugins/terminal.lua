return {
	{
		'akinsho/toggleterm.nvim',
		version = '*',

		cmd = {
			'ToggleTerm',
			'ToggleTermSendCurrentLine',
			'ToggleTermSendVisualLines',
			'ToggleTermSendVisualSelection',
			'ToggleTermSetName',
			'ToggleTermToggleAll',
		},

		keys = {
			{ '<leader>gs', '<CMD>ToggleTerm<CR>', desc = 'Toggle terminal' },
		},

		opts = {
			highlights = {
				NormalFloat = {
					link = 'NormalFloat',
				},
				FloatBorder = {
					link = 'FloatBorder',
				},
			},
			direction = 'float',
			float_opts = {
				border = 'rounded',
			},
		},
	},
}
