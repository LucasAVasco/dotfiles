return {
	{
		name = 'clangd',

		dir = mypaths.plugin_empty,
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
		},

		ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },

		config = function()
			require('lspconfig').clangd.setup{ capabilities = myplugfunc.lsp_get_capabilities(), cmd = { 'clangd', '--header-insertion=never' } }
		end
	}
}

