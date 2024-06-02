return {
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',

		opts = {
			ensure_installed = { 'lua', 'vim', 'vimdoc', 'markdown_inline' },  -- 'markdown_inline' is required to the new `Trouble` version
			sync_install = false,
			auto_install = true,  -- Install missing parser when entering a buffer that requires it

			highlight = { enable = true },
			incremental_selection = { enable = true },
			indent = { enable = true },
			matchup = { enable = true },
		},

		config = function(plugin, opts)
			require('nvim-treesitter.configs').setup(opts)
		end
	}
}
