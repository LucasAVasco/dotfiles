return {
	{
		-- This plugin improves the text objects related to 'a' and 'i'. This is not plugin related to artificial intelligence
		'echasnovski/mini.ai',
		version = false,

		config = function()
			require('mini.ai').setup()
		end
	},
	{
		'folke/flash.nvim',

		keys = {
			{
				'<leader>Ft',
				function ()
					require('flash').toggle()
				end, desc = 'Toggle Flash in search mode'
			},
			{
				'r', mode = { 'o' },  -- Flash remote motion
				function ()
					require('flash').remote()
				end, desc = 'At another position given by Flash'
			},
			{
				'<A-f>', mode = { 'n', 'v', 'o' },  -- Jump in normal and visual mode
				function ()
					require('flash').jump()
				end, desc = 'To a position given by Flash'
			},
			{
				'<A-t>', mode = { 'n', 'v', 'o' },  -- Select in normal and visual mode
				function ()
					require('flash').treesitter()
				end, desc = 'A treesitter area with Flash'
			},
			{
				'<A-s>', mode = {'n', 'v', 'o' },  -- Select in normal mode, jump in visual mode
				function ()
					require('flash').treesitter_search()
				end, desc = 'A search and treesitter area given by Flash'
			},
		},

		opts = {
			modes = {
				char = {
					jump_labels = true
				}
			}
		}
	}
}
