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

		config = function(_, opts)
			require('mason')  -- Configured in another file
			MYPLUGFUNC.ensure_mason_package_installed('tree-sitter-cli')  -- Required to use `:TSInstallFromGrammar`

			require('nvim-treesitter.configs').setup(opts)
		end
	}
}
