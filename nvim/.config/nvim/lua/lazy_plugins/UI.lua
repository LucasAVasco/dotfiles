---@class vim_ui_input_opts
---@field prompt? string Title of the prompt
---@field default? string Start value of the prompt
---@field completion? string Auto-completion type to use in the input. Same as on the `:help command-completion` page. E.g. 'dir'

return {
	{
		'folke/noice.nvim',

		dependencies = {
			'MunifTanjim/nui.nvim',
		},

		cond = MYVAR.not_in_vscode,

		event = 'VeryLazy',

		---@module "noice.config.init"
		---@type NoiceConfig
		opts = {
			popupmenu = {
				backend = 'cmp',
			},
			lsp = {
				override = {
					['cmp.entry.get_documentation'] = true,
					['vim.lsp.util.convert_input_to_markdown_lines'] = true,
					['vim.lsp.util.stylize_markdown'] = true,
				},
			},
			presets = {
				lsp_doc_border = true,
			},
			views = {
				cmdline_popup = {
					size = {
						width = '60%',
					},
				},
			},
		},

		config = function(_, opts)
			require('noice').setup(opts)

			MYPLUGFUNC.load_telescope_extension('noice', { 'noice' })

			-- Keymaps

			local noice_lsp = require('noice.lsp')

			---Add a key map to scroll in the hover and signature popups.
			---If there are not a popup to scroll, execute the normal command '<C-key>' and centralize vertically the cursor in the screen
			---@param key string Key to be mapped. E.g. 'd', 'u'
			---@param scroll_amount number Line count to scroll in the popup
			local function add_scroll_keymap(key, scroll_amount)
				local movement_keymap = vim.api.nvim_replace_termcodes('<C-' .. key .. '>zz', true, false, true)

				vim.keymap.set({ 'n', 'v', 'i' }, '<A-' .. key .. '>', function()
					-- Applies the scroll operation and ends
					if noice_lsp.scroll(scroll_amount) then
						return
					end

					-- Moves the cursor
					vim.cmd.normal({ movement_keymap, bang = true })
				end, { remap = false, silent = true })
			end

			add_scroll_keymap('d', 6)
			add_scroll_keymap('u', -6)
		end,
	},
}
