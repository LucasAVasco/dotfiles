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

---@class lazy_plugins.packages.mason_install_callbacks
---@field on_success? fun(receipt: InstallReceipt) Called when the package is successfully installed
---@field on_failure? fun(error: any) Called when the package fails to install
---@field on_after? fun() Called whether the package is installed or not (after the `on_success` or `on_failure` callbacks)

---Set a package to be installed after `mason.nvim` configuration
---
---If called before `mason.nvim` setup, save the package name. The `mason.nvim` configuration will install all pending packages. After this,
---any call to the current function will install the package instead of save it. This function does not starts `mason.nvim`. You need to do
---it by calling `require('mason')`.
---
---You can use this function inside the `init` or `config` function in your `lazy.nvim` configuration. Using it outside of these functions
---may result in it being called before `ensure_mason_package_installed()` is loaded.
---@param package_name string Package name. The same shown with the ':Mason' command
---@param callbacks? lazy_plugins.packages.mason_install_callbacks Callbacks.
function MYPLUGFUNC.ensure_mason_package_installed(package_name, callbacks)
	callbacks = callbacks or {}
	callbacks.on_success = callbacks.on_success or function() end
	callbacks.on_failure = callbacks.on_failure or function() end
	callbacks.on_after = callbacks.on_after or function() end

	if mason_configured then
		local package = require('mason-registry').get_package(package_name)
		if not package:is_installed() then
			package:install({}, function(success, receipt)
				if success then
					callbacks.on_success(receipt)
				else
					callbacks.on_failure(receipt)
				end
				callbacks.on_after()
			end)
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
		end,
	},
	{
		'williamboman/mason-lspconfig.nvim',

		cmd = {
			'LspInstall',
			'LspUninstall',
		},
	},
}
