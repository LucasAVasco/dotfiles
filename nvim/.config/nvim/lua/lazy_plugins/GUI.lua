return {
	{
		'ray-x/guihua.lua',

		build = 'cd lua/fzy && make',

		lazy = true,

		opts = {
			maps = {
				close_view = '<A-q>',
			},
		},
	},
}
