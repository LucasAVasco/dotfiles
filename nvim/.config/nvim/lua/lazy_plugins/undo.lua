return {
	{
		'mbbill/undotree',

		keys = {
			{
				'<leader>U',
				function()
					vim.cmd.UndotreeToggle()
					vim.cmd.UndotreeFocus()
				end,
			},
		},

		cmd = {
			'UndotreeFocus',
			'UndotreeHide',
			'UndotreePersistUndo',
			'UndotreeShow',
			'UndotreeToggle',
		},
	},
	{
		'debugloop/telescope-undo.nvim',

		dependencies = {
			'nvim-telescope/telescope.nvim',
		},

		lazy = true,

		init = function()
			MYPLUGFUNC.load_telescope_extension('undo', { 'undo' })
		end,
	},
}
