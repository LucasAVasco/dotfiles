--[[
	Snippets to create TODO comments

	Support the TODO comments of the `todo-comments.nvim` plugin (https://github.com/folke/todo-comments.nvim) and some others that I use

	If git `user.name` is set, this will be the author of the TODO comment. It will be inserted between parentheses and before the colon.
	This is used by `ruff` as described in rule TD002 (https://docs.astral.sh/ruff/rules/missing-todo-author/). But it can be used in
	languages other than Python.
]]

local ls = require('luasnip')
local s = ls.snippet
local f = ls.function_node

local todo_comments_list = {
	-- From `todo-comments.nvim`
	'TODO',
	'HACK',
	'WARN',
	'WARNING',
	'XXX',
	'PERF',
	'OPTIM',
	'PERFORMANCE',
	'OPTIMIZE',
	'NOTE',
	'INFO',
	'TEST',
	'TESTING',
	'PASSED',
	'FAILED',

	-- My TODO comments
	'NOPUSH',
}

--- Generate the text of the TODO comment to a LuaSnip function node
--- Add the git user name as the author of the TODO comment if it is configured (the 'user.name' option). The author is
--- specified between parenthesis after the TODO type and before the colon
--- The TODO text need to be provided in the `user_args` attribute of the `node_opts` table in the function node
---@param todo_text string Text of the TODO comment (E.g. 'INFO').
local function get_todo_comment_text(_, _, todo_text)
	-- Append the git user name between parenthesis to the TODO comment (before the colon).
	-- Example: # TODOCOMMENT(LucasAVasco): example of the result
	local git_user_name = vim.system({ 'git', 'config', 'user.name' }, { text = true }):wait().stdout
	if git_user_name then
		git_user_name = string.gsub(git_user_name, '\n', '')

		todo_text = todo_text .. '(' .. git_user_name .. ')'
	end

	return todo_text .. ': '
end

-- Snippets creation
local snippets = {}
for _, todo_text in pairs(todo_comments_list) do
	table.insert(
		snippets,
		s({
			trig = todo_text,
			name = todo_text .. ' comment',
			desc = 'Create a "' .. todo_text .. '" comment with the current git user name as the author',
		}, {
			f(get_todo_comment_text, {}, { user_args = { todo_text } }),
		})
	)
end

return snippets
