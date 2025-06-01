---@module 'my_configs.coverage.types'
---@type my_config.coverage.CoverageBuildFunction
local fn = function(_, callback)
	return vim.system({ 'go', 'test', '-coverprofile', 'coverage.out', './...' }, {}, callback)
end

return fn
