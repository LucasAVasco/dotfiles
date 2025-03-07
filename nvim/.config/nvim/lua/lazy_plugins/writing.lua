return {
	{
		'preservim/vim-pencil',

		cmd = {
			'HardPencil',
			'NoPencil',
			'Pencil',
			'PencilHard',
			'PencilOff',
			'PencilSoft',
			'PencilToggle',
			'SoftPencil',
			'TogglePencil',
		},
	},
	{
		'dhruvasagar/vim-table-mode',

		cmd = {
			'TableAddFormula',
			'TableSort',
			'Tableize',
			'TableModeRealign',
			'TableModeToggle',
			'TableEvalFormulaLine',
			'TableModeDisable',
			'TableModeEnable',
		},

		keys = {
			{ '<leader>t', desc = 'Table mode mappings' },
			{ '<leader>tA', "ggVG:'<,'>Tableize<CR>", desc = 'Tableize all file' },
		},
	},
}
