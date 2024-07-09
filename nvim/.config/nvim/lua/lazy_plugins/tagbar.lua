--[[ autodoc
	====================================================================================================
	Tagbar mappings (Plugin)[maps]                                                  *plugin-tagbar-maps*

	`<gt>` Open Tagbar.

	Some keymaps inside Tagbar~

	`?`        Show the keymaps.
	`*/zR/_`   Open all folds.
	`=/zM`     Close all folds.
	`x`        toggle the zoom of the tagbar.
	`s`        Toggle the sort mode (tag name, file name).
	`v`        Hide non public tags.
	`q`        quit.
]]


-- Adds a keymap to open all folds in the Tagbar with the '_' key
vim.api.nvim_create_autocmd({'BufEnter'}, {
	pattern = '__Tagbar__*', callback = function(info)
		vim.keymap.set('n', '_', '<CMD>TagbarSetFoldlevel 99<CR>', {
			buffer = info.buf,
			noremap = true,
			silent = true,
			desc = 'Open all folds. Similar to "*/zM"'
		})
	end
})


return {
	{
		'preservim/tagbar',

		keys = {
			{ 'gt', '<cmd>TagbarOpen fj<CR>', mode = 'n', noremap = true, silent = true, desc = 'Open Tagbar' },
		},

		init = function()
			vim.g.tagbar_width = 60

			-- Usability
			vim.g.tagbar_compact = 2  -- Does not show the Help message and blank lines
			vim.g.tagbar_singleclick = 1
			vim.g.tagbar_autoclose = 1
			vim.g.tagbar_autoshowtag = 1

			-- Tag information
			vim.g.tagbar_show_data_type = 1
			vim.g.tagbar_show_tag_linenumbers = 1
			vim.g.tagbar_show_tag_count = 1

			vim.g.tagbar_visibility_symbols = {
				-- public
				public = '⋅ ',
				protected = '󰞀 ',
				private = '󰌾 ',
			}
		end
	}
}
