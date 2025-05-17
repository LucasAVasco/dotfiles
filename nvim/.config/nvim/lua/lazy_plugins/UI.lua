---@class vim_ui_input_opts
---@field prompt? string Title of the prompt
---@field default? string Start value of the prompt
---@field completion? string Auto-completion type to use in the input. Same as on the `:help command-completion` page. E.g. 'dir'

return {
	{
		'folke/noice.nvim',
		event = 'VeryLazy',

		dependencies = {
			'MunifTanjim/nui.nvim',
		},

		---@module "noice.config.init"
		---@type NoiceConfig
		opts = {
			popupmenu = {
				backend = 'cmp',
			},
			lsp = {
				override = {}, -- Will be fulfilled in the configuration function
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

		config = function(plugin, opts)
			-- Name of the module to load. I do not hard-coded it because `typos_ls` is showing some warnings
			local plugin_main = plugin.name:sub(1, plugin.name:find('.', 1, true) - 1)
			local nc_lsp = require(plugin_main .. '.lsp')

			-- Enables all LSP overrides
			local lsp_overrides = {
				'cmp.entry.get_documentation',
				'vim.lsp.util.convert_input_to_markdown_lines',
				'vim.lsp.util.stylize_markdown',
			}

			for _, override in pairs(lsp_overrides) do
				opts.lsp.override[override] = true
			end

			-- Setup
			require(plugin_main).setup(opts)

			MYPLUGFUNC.load_telescope_extension(plugin_main, { plugin_main })

			-- Keymaps

			---Add a key map to scroll in the hover and signature popups.
			---If there are not a popup to scroll, execute the normal command '<C-key>' and centralize vertically the cursor in the screen
			---@param key string Key to be mapped. E.g. 'd', 'u'
			---@param scroll_amount number Line count to scroll in the popup
			local function add_scroll_keymap(key, scroll_amount)
				local movement_keymap = vim.api.nvim_replace_termcodes('<C-' .. key .. '>zz', true, false, true)

				vim.keymap.set({ 'n', 'v', 'i' }, '<A-' .. key .. '>', function()
					-- Applies the scroll operation and ends
					if nc_lsp.scroll(scroll_amount) then
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
