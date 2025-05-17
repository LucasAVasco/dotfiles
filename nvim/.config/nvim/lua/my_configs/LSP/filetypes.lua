---Table with the server to override and the new file types values
---@type table<string, string[]|string> Relates the LSP server identifier (used by lspconfig) to its override file types
return {
	clangd = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
}
