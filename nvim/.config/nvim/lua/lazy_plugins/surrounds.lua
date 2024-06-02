--[[ autodoc
	====================================================================================================
	Surrounds mappings (Plugin)[maps]                                             *plugin-surronds-maps*

	The Meta key (<M-) is the same as the Alt key (<A-) key. I only use the <M- prefix because the
	original plugin also uses.

	`<M-p>` Enable or disable auto-pairs plugin.

	If you have trouble with the fly mode, try the Shortcuts:

	`<M-b>` Insert the next pair ending. If the fly mode is on, and you pressed the pair terminator
	before (go to the next pair), it will jump to the last position (before go to the next pair) and
	insert the pair ending at that position. (Backinsert)

	`<M-n>` Jump to the next pair ending.

	`<M-e>` Send the pair ending to the end of the next pair. (Fast Wrap)
]]


return {
	'tpope/vim-surround',

	{
		'jiangmiao/auto-pairs',

		init = function()
			vim.g.AutoPairsFlyMode = 1  -- If enabled, Speeds up some times, but can be annoying. See the description of the Toggle auto-pairs key.
			vim.g.AutoPairsMapCh = 0    -- Disable the mapping of <C-h>. It is equal to <C-BS>, that i want to use for other things.
		end
	}
}
