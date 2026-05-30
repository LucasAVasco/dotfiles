local M = {}

local parsers = require('nvim-treesitter.parsers')

---Returns `true` if the language has a tree-sitter parser
---@param lang any
---@return boolean
function M.lang_has_parser(lang)
	return parsers[lang] ~= nil
end

---Returns `true` if the buffer has a tree-sitter parser
---@param buffer integer
---@return boolean
function M.buffer_has_parser(buffer)
	local lang = vim.treesitter.language.get_lang(vim.bo[buffer].filetype)
	return M.lang_has_parser(lang)
end

---Returns the tree-sitter language of the buffer
---@param buffer integer
function M.get_lang_from_buffer(buffer)
	return vim.treesitter.language.get_lang(vim.bo[buffer].filetype)
end

return M
