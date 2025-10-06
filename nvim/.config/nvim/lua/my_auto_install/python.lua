local exec = require('my_libs.exec')

MYPLUGFUNC.ensure_mason_package_installed('python-lsp-server', {
	on_success = function()
		exec.System:new({
			'bash',
			'-c',
			[[
		source ~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/activate
		pip install pylsp-mypy python-lsp-ruff
		]],
		})
	end,
})
