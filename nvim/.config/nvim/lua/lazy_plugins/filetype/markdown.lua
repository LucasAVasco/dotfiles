return {
	{
		-- Based in the configuration provided at https://github.com/MeanderingProgrammer/render-markdown.nvim
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = {
			-- Optional
			'nvim-tree/nvim-web-devicons',
			'nvim-treesitter/nvim-treesitter',
		},

		ft = 'markdown',

		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			code = {
				style = 'language', -- Only style the language indicator
			},
		},
	},
	{
		'iamcco/markdown-preview.nvim',
		lazy = true,

		cmd = {
			'MarkdownPreview',
			'MarkdownPreviewStop',
			'MarkdownPreviewToggle',
		},

		build = 'cd app && npm install && git restore .',

		init = function()
			vim.g.mkdp_browser = 'default_open'
		end,

		config = function()
			MYFUNC.reset_filetype('markdown')
		end,
	},
	{
		'renerocksai/telekasten.nvim',
		dependencies = {
			'nvim-telekasten/calendar-vim',
			'nvim-telescope/telescope.nvim',
		},

		cmd = 'Telekasten',

		keys = {
			{ '<leader>Z/', '<CMD>Telekasten search_notes<CR>', desc = 'Search in notes' },
			{ '<leader>Zc', '<CMD>Telekasten show_calendar<CR>', desc = 'Show calendar' },
			{ '<leader>Zgd', '<CMD>Telekasten goto_today<CR>', desc = 'Go to today note' },
			{ '<leader>Zgf', '<CMD>Telekasten follow_link<CR>', desc = 'Follow link' },
			{ '<leader>Zgn', '<CMD>Telekasten find_notes<CR>', desc = 'Go to note' },
			{ '<leader>Zgw', '<CMD>Telekasten goto_thisweek<CR>', desc = 'Go to this week note' },
			{ '<leader>Zil', '<CMD>Telekasten insert_link<CR>', desc = 'Insert link' },
			{ '<leader>Zim', '<CMD>Telekasten insert_img_link<CR>', desc = 'Insert image link' },
			{ '<leader>Znn', '<CMD>Telekasten new_note<CR>', desc = 'New note' },
			{ '<leader>Zr', '<CMD>Telekasten show_backlinks<CR>', desc = 'Show backlinks (references to the current note)' },

			-- Non-Telekasten key mappings
			{ '<leader>Zgp', '<CMD>Telescope find_files cwd=' .. MYPATHS.org .. '/pages<CR>', desc = 'Go to page' },
			{
				'<leader>Znp',
				function()
					vim.ui.input({ prompt = 'Page title' }, function(page_name)
						if page_name then
							vim.cmd.edit({ MYPATHS.org .. '/pages/' .. page_name .. '.md', bang = true })
						end
					end)
				end,
				desc = 'New page',
			},
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>Z', 'Zettelkasten keymaps', 'n')
		end,

		config = function()
			require('telekasten').setup({
				home = MYPATHS.org .. '/notes',
				dailies = MYPATHS.org .. '/journals',
				weeklies = MYPATHS.org .. '/journals',

				auto_set_filetype = false, -- The `telekasten` file-type disables the features of other markdown plugins
				journal_auto_open = true, -- Affects 'go to today' and 'go to this week'
			})
		end,
	},
}
