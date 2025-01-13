return {
	'kylechui/nvim-surround',
	version = '*',
	keys = {
		'cs',
		'cS',
		'ys',
		'yS',
		'ds',
		'dS', -- Normal mode
		{ '<C-g>s', mode = 'i' },
		{ '<C-g>S', mode = 'i' }, -- Insert mode
		{ 'S', mode = 'v' },
		{ 'gS', mode = 'v' }, -- Visual mode
	},

	opts = {
		-- Highlights the surrounds to be replaced in normal mode
		highlight = {
			duration = 700, -- milliseconds
		},
	},
}
