--- Returns if Pyright is enabled for the current context
-- If there are any Pylsp configuration files, it will disable Pyright. Otherwise will check if any of the Pyright configuration files exists.
-- If any of them exists, it will enable Pyright. If there are no configuration files (neither Pylsp nor Pyright), it will disable Pyright.
-- @return boolean True if Pyright is enabled, false otherwise
local function is_pyright_enabled()
	local pylsp_config_files = { 'pylsp-mypy.cfg' }

	-- DIsable if any of the Pylsp configuration files exists
	for _, file in ipairs(pylsp_config_files) do
		if vim.fn.filereadable(file) == 1 then
			return false
		end
	end

	local pyright_config_files = { 'pyrightconfig.json', 'pyrightconfig.jsonc' }

	-- Enable Pyright if any of the configuration files exists
	for _, file in ipairs(pyright_config_files) do
		if vim.fn.filereadable(file) == 1 then
			return true
		end
	end

	-- Disable Pyright if there are no configuration files (either Pylsp or Pyright)
	return false
end


return {
	{
		name = 'pyright',

		dir = mypaths.plugin_empty,
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
		},

		ft = 'python',

		enabled = is_pyright_enabled,

		config = function()
			require('lspconfig').pyright.setup{ }
		end
	},
	{
		name = 'pylsp',

		dir = mypaths.plugin_empty,
		dependencies = {
			'hrsh7th/cmp-nvim-lsp',
		},

		ft = 'python',

		enabled = function()
			return not is_pyright_enabled()
		end,

		config = function()
			require('lspconfig').pylsp.setup{ }
		end
	}
}
