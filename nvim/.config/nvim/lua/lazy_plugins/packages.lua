--[[
	Plugins to manage external packages

	Add the `MYPLUGFUNC.ensure_mason_package_installed()` function to ensure that `mason.nvim` will install a package. You can use this
	function in any part of you `lazy.nvim` configuration code (inside the `config` and `init` functions). The package will be installed
	after `mason.nvim` setup (call to `require('mason')`)
]]


-- #region API to ensure that a `mason.nvim` package is installed

---@type string[]
local mason_packages_to_install = {}

local mason_configured = false

---Set a package to be installed after `mason.nvim` configuration
---
---If called before `mason.nvim` setup, save the package name. The `mason.nvim` configuration will install all pending packages. After this,
---any call to the current function will install the package instead of save it. This function does not starts `mason.nvim`. You need to do
---it by calling `require('mason')`.
---
---You can use this function inside the `init` or `config` function in your `lazy.nvim` configuration. Using it outside of these functions
---may result in it being called before `ensure_mason_package_installed()` is loaded.
---@param package_name string Package name. The same shown with the ':Mason' command
function MYPLUGFUNC.ensure_mason_package_installed(package_name)
	if mason_configured then
		local package = require('mason-registry').get_package(package_name)
		if not package:is_installed() then
			package:install()
		end
	else
		table.insert(mason_packages_to_install, package_name)
	end
end

-- #endregion


return {
	{
		'williamboman/mason.nvim',

		config = function()
			require('mason').setup()

			-- Installs the pending packages
			mason_configured = true
			for _, package in pairs(mason_packages_to_install) do
				MYPLUGFUNC.ensure_mason_package_installed(package)
			end
			mason_packages_to_install = {}
		end
	},
	{
		'williamboman/mason-lspconfig.nvim',

		cmd = {
			'LspInstall',
			'LspUninstall',
		},
	}
}
