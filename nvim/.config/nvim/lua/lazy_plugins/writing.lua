return {
	{
		'preservim/vim-pencil',

		cond = MYVAR.not_in_vscode,

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
			{ '<leader>tm', desc = 'Toggle table mode' },
			{ '<leader>tA', "ggVG:'<,'>Tableize<CR>", desc = 'Tableize all file' },
			{ mode = { 'n', 'v' }, '<leader>tt', desc = 'Tableize line or selection' },
		},
	},
}
