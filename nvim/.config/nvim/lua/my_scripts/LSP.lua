--[[ autodoc
	====================================================================================================
	LSP mappings[maps]                                                                  *mycfg-lsp-maps*

	`<leader>gd`    Go to definition
	`<leader>gD`    Go to declaration
	`<leader>gi`    Go to implementation
	`<leader>gt`    Go to type definition

	`<A-h>`         Show hover information
	`<leader>Lr`    Show references
	`<leader>Lh`    Show hover
	`<leader>Ls`    Show symbols
	`<leader>Lic`   Show incoming calls
	`<leader>Loc`   Show outgoing calls

	`<leader>Lr`    Rename
	`<leader>La`    Code action
	`<leader>Lf`    Format

	`<leader>Lws`   Workspace symbol
	`<leader>Lwa`   Add workspace folder
	`<leader>Lwr`   Remove workspace folder
	`<leader>Lwl`   List workspace folders

	`<leader>Lcr`   Codelens run

	====================================================================================================
	LSP commands[cmd]                                                                   *mycfg-lsp-cmds*

	`LspInfo`   Show the language server info
	`LspLog`    Show the language server log
]]

local default_options = MYFUNC.decorator_create_options_table({ noremap = true, silent = true })

-- Go to
vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, default_options('Go to LSP definition'))
vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, default_options('Go to LSP definition'))
vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, default_options('Go to LSP declaration'))
vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, default_options('Go to LSP implementation'))
vim.keymap.set('n', '<leader>gt', vim.lsp.buf.type_definition, default_options('Go to LSP type definition'))

-- Show information
MYPLUGFUNC.set_keymap_name('<leader>L', 'LSP mappings', { 'n' })
vim.keymap.set('n', '<leader>Lr', vim.lsp.buf.references, default_options('Show LSP references'))
vim.keymap.set('n', '<leader>Lh', vim.lsp.buf.hover, default_options('Show LSP hover'))
vim.keymap.set('n', '<leader>Ls', vim.lsp.buf.document_symbol, default_options('Show LSP symbols'))
vim.keymap.set('n', '<leader>Lic', vim.lsp.buf.incoming_calls, default_options('Show LSP incoming calls'))
vim.keymap.set('n', '<leader>Loc', vim.lsp.buf.outgoing_calls, default_options('Show LSP outgoing calls'))
vim.keymap.set('n', '<leader>Lih', function()
	local inlay_hint_is_enabled = vim.lsp.inlay_hint.is_enabled()
	vim.notify((inlay_hint_is_enabled and 'Disabling' or 'Enabling') .. ' inlay hints')
	vim.lsp.inlay_hint.enable(not inlay_hint_is_enabled)
end, default_options('Toggle LSP inlay hints visualization'))

-- Manage the code
vim.keymap.set('n', '<leader>Lr', vim.lsp.buf.rename, default_options('Code rename with LSP'))
vim.keymap.set('n', '<leader>La', vim.lsp.buf.code_action, default_options('LSP code action'))
vim.keymap.set('n', '<leader>Lf', vim.lsp.buf.format, default_options('Code format with LSP'))

-- Workspaces
MYPLUGFUNC.set_keymap_name('<leader>Lw', 'LSP Workspaces mappings', { 'n' })
vim.keymap.set('n', '<leader>Lws', vim.lsp.buf.workspace_symbol, default_options('List LSP workspace symbols'))
vim.keymap.set('n', '<leader>Lwa', vim.lsp.buf.add_workspace_folder, default_options('Add LSP workspace folder'))
vim.keymap.set('n', '<leader>Lwr', vim.lsp.buf.remove_workspace_folder, default_options('Remove LSP workspace folder'))

vim.keymap.set('n', '<leader>Lwl', function()
	local folder_num = 1
	local to_print = 'Workspaces folders: '

	-- The workspaces will be listed with its number and between quotes
	for _, folder in ipairs(vim.lsp.buf.list_workspace_folders()) do
		to_print = to_print .. '[' .. tostring(folder_num) .. ']: "' .. folder .. '", '
		folder_num = folder_num + 1
	end

	print(to_print)
end, default_options('List LSP workspace folders'))

-- Codelens
MYPLUGFUNC.set_keymap_name('<leader>Lc', 'LSP Codelens mappings', { 'n' })
vim.keymap.set('n', '<leader>Lcr', vim.lsp.codelens.run, default_options('Run LSP codelens of the current line'))

--- Return a function that refreshes the code lens in a specific buffer
--- The `vim.lsp.codelens.refresh()` function refreshes the code lens in all buffers. To refresh the code lens of a specif buffer, we need to
--- provide the buffer number to this function. The current function automatize this task by returning a function that calls
--- `vim.lsp.codelens.refresh()` only to the provided client and buffer
---@param client_id number Number of the LSP client
---@param buffer_nr number Number of the buffer to refresh the code lens
---@return function refresh_function Function that refreshes the code lens in the specified buffer
local function get_refresh_codelens_function(client_id, buffer_nr)
	return function()
		vim.lsp.codelens.refresh({ client_id = client_id, bufnr = buffer_nr })
	end
end

-- Auto commands. Need to check if the language server supports it. See the capabilities at:
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#serverCapabilities
local LSP_group = vim.api.nvim_create_augroup('LSPGroup', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
	group = LSP_group,
	callback = function(args)
		local buffer_nr = args.buf
		local client_id = args.data.client_id
		local client = vim.lsp.get_client_by_id(client_id)

		-- The client need to exist to be able to query the capabilities
		if client == nil then
			return
		end

		-- Shows the codelens
		if client.server_capabilities.codeLensProvider then
			vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'CursorHold' }, {
				group = LSP_group,
				buffer = buffer_nr,
				callback = get_refresh_codelens_function(client_id, buffer_nr),
			})
		end
	end,
})
