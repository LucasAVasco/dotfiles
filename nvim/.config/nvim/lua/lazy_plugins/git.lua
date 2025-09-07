--[[ autodoc
	====================================================================================================
	Git commands (Plugin)[cmd]                                                     *plugin-git-commands*

	Fugitive~

	`Git`                   Show git status
	`Git difftool {, -y}`   Shows each file diff in the quickfix. With -y, instead opens Gdiffsplit.
	`Git mergetool`         Like difftool, but for merge conflicts.
	`Ggrep -q`              Shows the results of the 'git grep' in the quickfix.
	`Gclog`                 Shows the git log in the quickfix.
	`G{v,h}diffsplit`       Shows the diff in a vertical or horizontal split.

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
	{
		'tpope/vim-fugitive',

		cmd = {
			'G',
			'Git',
			'Ggrep',
			'Glgrep',
			'Gclog',
			'Gllog',
			'Gcd',
			'Glcd',
			'Gedit',
			'Gtabedit',
			'Gpedit',
			'Gsplit',
			'Gvsplit',
			'Gdrop',
			'Gread',
			'Gwrite',
			'Gwq',
			'Gdiffsplit',
			'Gvdiffsplit',
			'Ghdiffsplit',
			'GMove',
			'GRename',
			'GDelete',
			'GRemove',
			'GUnlink',
			'GBrowse',
		},
	},
	{
		'sindrets/diffview.nvim',

		cmd = {
			'DiffviewClose',
			'DiffviewFileHistory',
			'DiffviewFocusFiles',
			'DiffviewLog',
			'DiffviewOpen',
			'DiffviewRefresh',
			'DiffviewToggleFiles',
		},
	},
	{
		'lewis6991/gitsigns.nvim',

		event = 'User MyEventOpenEditableFile',

		cmd = 'Gitsigns',

		opts = {
			sign_priority = 6,
			update_debounce = 100,
			max_file_length = 20000, -- Disable gitsigns if file is longer than this number of lines
			signcolumn = true,

			-- #region Style options

			signs = {
				untracked = { text = '¦', show_count = true },
				add = { text = '┃', show_count = true },
				change = { text = '󰇙', show_count = true },
				topdelete = { text = '󰘣', show_count = true },
				delete = { text = '󰘡', show_count = true },
				changedelete = { text = '', show_count = true },
			},

			count_chars = {
				'₁',
				'₂',
				'₃',
				'₄',
				'₅',
				'₆',
				'₇',
				'₈',
				'₉',
				['+'] = '₊',
			},

			preview_config = { -- Same values passed to `nvim_open_win`
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

		config = function(_, opts)
			local gitsigns = require('gitsigns')

			gitsigns.setup(opts)

			-- Keymaps

			local n_mode = 'n'
			local n_v_mode = { 'n', 'v' }
			local get_opts = MYFUNC.decorator_create_options_table({
				noremap = true,
				silent = true,
			})

			MYPLUGFUNC.set_keymap_name('<leader>G', 'Git mappings', n_v_mode)
			vim.keymap.set(n_mode, '<leader>Gh', gitsigns.preview_hunk_inline, get_opts('Preview current hunk'))
			vim.keymap.set(n_mode, '<leader>Gb', gitsigns.toggle_current_line_blame, get_opts('Toggle current line blame'))
			vim.keymap.set(n_mode, '<leader>Gw', gitsigns.toggle_word_diff, get_opts('Toggle word diff'))
			vim.keymap.set(n_mode, '<leader>Gl', gitsigns.setloclist, get_opts('Show hunks in loclist'))
			vim.keymap.set(
				n_mode,
				'<leader>GL',
				MYFUNC.decorator_call_function(gitsigns.setloclist, { 0, 'all' }),
				get_opts('Show all hunks in loclist')
			)

			-- Hunks management

			vim.keymap.set(n_mode, '<leader>GS', gitsigns.stage_buffer, get_opts('Stage buffer'))
			vim.keymap.set(n_mode, '<leader>GR', gitsigns.reset_buffer, get_opts('Reset buffer'))

			vim.keymap.set(n_v_mode, '<leader>Gs', function()
				local mode = vim.api.nvim_get_mode().mode
				vim.notify(mode)

				if mode == 'n' then
					gitsigns.stage_hunk()
				elseif mode == 'v' or mode == 'V' then
					local selected_area = MYFUNC.get_visual_selected_area(0)
					gitsigns.stage_hunk({ selected_area.cursor_line, selected_area.start_selected_line })
				end
			end, get_opts('Stage hunk'))

			vim.keymap.set(n_v_mode, '<leader>Gr', function()
				local mode = vim.api.nvim_get_mode().mode

				if mode == 'n' then
					gitsigns.reset_hunk()
				elseif mode == 'v' or mode == 'V' then
					local selected_area = MYFUNC.get_visual_selected_area(0)
					gitsigns.reset_hunk({ selected_area.cursor_line, selected_area.start_selected_line })
				end
			end, get_opts('Reset hunk'))

			-- Operators

			vim.keymap.set({ 'o', 'x' }, 'ih', gitsigns.select_hunk, get_opts('Select hunk'))

			-- Override default ]c and [c mappings

			--- Decorator that applies a fallback that runs a normal command if not in diff mode
			---@param func fun(args: table) Function that will be called if not in diff mode
			---@param func_args table Arguments passed to the function
			---@param fallback_command string Normal command that will be called if in diff mode
			---@return fun() decorated_function
			local function decorator_fallback_diff_mode(func, func_args, fallback_command)
				return function()
					if not vim.wo.diff then
						func(unpack(func_args))

					-- Fallback to normal commands without overriding the default mapping
					else
						vim.cmd.normal({ fallback_command, bang = true }) -- Need the bang option to not override the default mapping
					end
				end
			end

			vim.keymap.set(n_mode, ']c', decorator_fallback_diff_mode(gitsigns.nav_hunk, { 'next' }, ']c'), get_opts('Next change'))
			vim.keymap.set(n_mode, '[c', decorator_fallback_diff_mode(gitsigns.nav_hunk, { 'prev' }, '[c'), get_opts('Previous change'))
			vim.keymap.set(n_mode, ']C', decorator_fallback_diff_mode(gitsigns.nav_hunk, { 'last' }, 'G'), get_opts('Last change'))
			vim.keymap.set(n_mode, '[C', decorator_fallback_diff_mode(gitsigns.nav_hunk, { 'first' }, 'gg'), get_opts('First change'))
		end,
	},
}
