---@module 'my_plugins.dedent_ts_injections'
---
---Add the '@injection.dedented-content' capture. It works like the '@injection;content' capture, but the injected text is dedented before
---being parsed.
---
---Add the following options (can be set with `#set!` in the query):
---
---* `injection.ignore-non-indented-first-line`: Ignore the indentation of the first line if it is 0. Set to 'true' or 1 to enable it.
---* `injection.indent-size`: Number of whitespaces to remove. If not provided, it will be calculated automatically from the text.

local treesitter = require('my_plugin_libs.treesitter')

local M = {}

local highlight_namespace = vim.api.nvim_create_namespace('dedent_ts_injections')

---@class my_plugins.dedent_ts_injections.Opts: MyFunctions.DedentOpts

---Inject the highlights of the given language in the node
---@param node TSNode Node to inject the highlights
---@param buffer integer Buffer of the node
---@param lang string Language to inject in the node
---@param opts my_plugins.dedent_ts_injections.Opts
local function inject_highlights(node, buffer, lang, opts)
	-- Dedented text
	local text = vim.treesitter.get_node_text(node, buffer)
	if not text then
		return
	end

	-- Ignore the first line if the indent size is 0. This is useful if it has a indentation different from the other lines (e.g. in
	-- Python docstrings the first line may be after the '"""' and therefore have no indentation, but the other lines are indented)
	local dedented, indent = MYFUNC.dedent(text, opts)

	-- Parser for the dedented text
	local parser = vim.treesitter.get_string_parser(dedented, lang)
	local tree = parser:parse()[1]
	if not tree then
		return
	end

	-- Query to get the highlights of the injected text
	local highlights_query = vim.treesitter.query.get(lang, 'highlights')
	if not highlights_query then
		return
	end

	-- Add the highlights to the buffer

	local original_start_row, original_start_col = node:start()
	for id, injected_node in highlights_query:iter_captures(tree:root(), '', 0, -1) do
		local start_row, start_col, end_row, end_col = injected_node:range() -- Inside the dedented text

		-- Offset the start and end rows and columns so the positions at the injected node are the same as the positions at the original
		-- node

		-- The first line may have a different indentation than the other lines, so we need to adjust the columns of the first line
		if start_row == 0 then
			start_col = start_col + original_start_col
		else
			start_col = start_col + indent
		end
		if end_row == 0 then
			end_col = end_col + original_start_col
		else
			end_col = end_col + indent
		end

		start_row = start_row + original_start_row
		end_row = end_row + original_start_row

		-- Highlight group

		local capture = highlights_query.captures[id]
		local hl_group = '@' .. capture

		vim.api.nvim_buf_set_extmark(buffer, highlight_namespace, start_row, start_col, {
			end_row = end_row,
			end_col = end_col,
			hl_group = hl_group,
			priority = 200,
		})
	end
end

---Create highlights for the injected text in the buffer
---@param buffer integer
local function create_highlights(buffer)
	-- Does not make sense to show injected highlights if the buffer is not highlighted
	if not vim.treesitter.highlighter.active[buffer] then
		return
	end

	-- Tree-sitter language
	local lang = treesitter.get_lang_from_buffer(buffer)
	if lang == nil then
		return
	end
	if not treesitter.lang_has_parser(lang) then
		return
	end

	-- Parsed tree
	local parser = vim.treesitter.get_parser(buffer, lang)
	if not parser then
		return
	end

	local tree = parser:parse()[1]
	if not tree then
		return
	end

	-- Query to get the injected text
	local query = vim.treesitter.query.get(lang, 'injections')
	if not query then
		return
	end

	-- Iterate over the injected text and add the highlights to the buffer

	for id, node, metadata in query:iter_captures(tree:root(), buffer) do
		local capture = query.captures[id]
		if capture == 'injection.dedented-content' then
			local inject_lang = metadata['injection.language']
			if type(inject_lang) ~= 'string' or not treesitter.lang_has_parser(inject_lang) then
				return
			end

			local ignore_first_line_indentation = metadata['injection.ignore-first-line-indentation']

			---@type my_plugins.dedent_ts_injections.Opts
			local opts = {
				ignore_first_line_indentation = ignore_first_line_indentation == '1' or ignore_first_line_indentation == 'true',
				indent_size = tonumber(metadata['injection.indent-size']),
			}

			inject_highlights(node, buffer, inject_lang, opts)
		end
	end
end

---Setup the plugin
function M.setup()
	vim.api.nvim_set_decoration_provider(highlight_namespace, {
		on_win = function(_, _, buffer)
			-- Clear previous highlights
			vim.api.nvim_buf_clear_namespace(buffer, highlight_namespace, 0, -1)

			-- Re-highlight
			create_highlights(buffer)

			return false
		end,
	})
end

return M
