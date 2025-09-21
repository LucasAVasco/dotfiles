local git = require('my_libs.git')

local ls = require('luasnip')
local s = ls.snippet
local f = ls.function_node

local function configure_cwd_as_git_root(_, _, _)
	vim.g.cmp_pth_cwd = git.get_root_dir('.') or '.'

	-- Reset the `cmp_pth_cwd` when leaving insert mode
	vim.api.nvim_create_autocmd('InsertLeave', {
		callback = function()
			vim.g.cmp_pth_cwd = nil
			return true
		end,
	})

	return ''
end

return {
	-- Insert a ANSI color escape
	s({
		trig = 'cmp-path-git-root-as-cwd',
		name = 'Use git root in cmp path.',
		desc = 'Makes cmp-path use the Git root directory as the current working directory.',
	}, {
		f(configure_cwd_as_git_root, {}),
	}),
}
