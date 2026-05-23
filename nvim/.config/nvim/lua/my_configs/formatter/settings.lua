local Config = {
	---@type table<string, string[]> Map each file-type to a list of available code-formatters.
	filetype2formatter = {
		lua = { 'stylua' },
		yaml = { 'prettier' },
		json = { 'prettier' },
		jsonc = { 'prettier' },
		markdown = { 'markdown-toc', 'prettier' },
		javascript = { 'prettier' },
		typescript = { 'prettier' },
		vue = { 'prettier' },
		go = { 'gofmt' },
		sql = { 'sql_formatter' },
		tex = { 'tex-fmt' },
		c = { 'clang-format' },
		cpp = { 'clang-format' },
		rust = { 'rustfmt' },
		cmake = { 'cmake_format' },
	},

	---@type string[] List of code formatters that should not notify the user if they can not be installed automatically with 'mason.nvim'
	no_notify_if_can_not_install = {
		'gofmt',
		'rustfmt',
	},
}

return Config
