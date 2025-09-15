local nodejs_package_manager = require('my_libs.nodejs.package_manager')

---@module 'my_configs.coverage.types'
---@type my_config.coverage.CoverageBuildFunction
local fn = function(_, callback)
	local manager, err = nodejs_package_manager.search('.')
	if err then
		return nil, 'Failed to find package manager: ' .. err
	end

	return vim.system({ manager, 'run', 'coverage' }, {}, callback)
end

return fn
