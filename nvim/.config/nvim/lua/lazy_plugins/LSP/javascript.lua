return {
	{
		name = 'tsserver',

		dir = mypaths.plugin_empty,
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
		},

		ft = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },

		config = function()
			require('lspconfig').tsserver.setup{ capabilities = myplugfunc.lsp_get_capabilities() }

			myfunc.add_setup_command('lsp configure tsserver', function()
				vim.cmd('new')
				local job = vim.fn.termopen({'yarn dlx @yarnpkg/sdks base'})
				vim.fn.jobwait({job})  -- Wait for the job to finish

				-- Restart TSServer
				myplugfunc.lsp_restart_server()
			end)
		end
	}
}
