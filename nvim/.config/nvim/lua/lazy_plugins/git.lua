--[[ autodoc
	====================================================================================================
	Git commands (Plugin)[cmd]                                                     *plugin-git-commands*

	Fugitive~

	`Git`                   Show git status
	`Git difftool {, -y}`   Shows each file diff in the quickfix. With -y, insted opens Gdiffsplit.
	`Git mergetool`         Like difftool, but for merge conflicts.
	`Ggrep -q`              Shows the results of the 'git grep' in the quickfix.
	`Gclog`                 Shows the git log in the quickfix.
	`G{v,h}diffsplit`       Shows the diff in a vertical or horizontal split.

	Gitsigns~

	`Gitsigns toggle_current_line_blame`   Toggle the visibility of the current line blame
	`Gitsigns setloclist`                  Open the location list with the current git hunks

	====================================================================================================
	Git mappings (Plugin)[maps]                                                        *plugin-git-maps*

	Fugitive~

	Inside the git status command: ':Git', you can use the following mappings:

	`-`        Git Add or Git Restore a file.
	`s/u/U`    Stage, unstage, unstage all.
	`=`        Shows the diff inline.
	`P`        Git add and Git Reset, but with --patch the file.
	`1p`       Open the file in the preview window and edit it.
	`d{h,v}`   Shows the diff in a vertical or horizontal split.
	`{o,O}`    Open the file in a split or new tab.
	`d?`       Open help

	Inside the Git log command: ':Git log', you can use the following mappings:
	`ri`   Rebase interactively.
	`ra`   Abort rebase.

	gitsigns~

	`{[,]}c`       Jump to next/previous hunk
	`<Leader>hp`   Preview current hunk
]]


return {
	'tpope/vim-fugitive',

	{
		'lewis6991/gitsigns.nvim',

		opts = {
			sign_priority = 6,
			update_debounce = 100,
			max_file_length = 20000, -- Disable gitsigns if file is longer than this number of lines
			signcolumn = true,

			-- #region Style options

			signs = {
				untracked    = { text = '¦' , show_count = true },
				add          = { text = '┃' , show_count = true },
				change       = { text = '⸾' , show_count = true },
				topdelete    = { text = '󰘣' , show_count = true },
				delete       = { text = '󰘡' , show_count = true },
				changedelete = { text = '⭍' , show_count = true },
			},

			count_chars = {
				'₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉',
				['+'] = '₊'
			},

			preview_config = {  -- Same values passed to `nvim_open_win`
				style = 'minimal',
				border = 'rounded',
				row = 1,
				col = 1,
				relative = 'cursor',
			},

			current_line_blame_opts = {
				delay = 0,
				ignore_whitespace = false,
				virt_text = true,
				virt_text_pos = 'right_align',
				virt_text_priority = 100,
			},

			-- #endregion
		},

		config = function(plugin, opts)
			local gitsigns = require('gitsigns')

			gitsigns.setup(opts)

			-- Keymaps
			local options = myfunc.decorator_create_options_table({
				noremap = true,
				silent = true
			})

			myplugfunc.set_keymap_name('<leader>h', 'Gitsigns hunk mappings', {'n'})
			vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, options('Preview current hunk'))

			myplugfunc.set_keymap_name('<leader>G', 'Git mappings', {'n'})
			myplugfunc.set_keymap_name('<leader>Gb', 'Git line blame mappings', {'n'})
			vim.keymap.set('n', '<leader>Gbt', gitsigns.toggle_current_line_blame, options('Toggle current line blame'))

			-- Override default ]c and [c mappings

			--- Decorator that applies a fallback that runs a normal command if not in diff mode
			-- @param func Function that will be called if not in diff mode
			-- @param fallback_command Normal command that will be called if in diff mode
			-- @return Decorated function
			local function decorator_fallback_diff_mode(func, fallback_command)
				return function()
					if not vim.wo.diff then
						func()

					-- Fallback to normal commands without overriding the default mapping
					else
						vim.cmd.normal({ fallback_command, bang = true })  -- Need the bang option to not override the default mapping
					end
				end
			end

			vim.keymap.set('n', ']c', decorator_fallback_diff_mode(gitsigns.next_hunk, ']c'), options('Next hunk'))
			vim.keymap.set('n', '[c', decorator_fallback_diff_mode(gitsigns.prev_hunk, '[c'), options('Previous hunk'))
		end
	}
}
