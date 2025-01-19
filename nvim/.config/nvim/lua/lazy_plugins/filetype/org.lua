return {
	{
		'nvim-orgmode/orgmode',
		ft = { 'org' },

		-- Not all key maps are register here. Only the ones I may use outside a '*.org' file
		keys = {
			{ '<leader>oa' }, -- Open agenda
			{ '<leader>oc' }, -- Open capture mode
		},

		opts = {
			-- Keywords
			org_todo_keywords = { 'TODO', 'NEXT', 'PROGRESS', '|', 'DONE', 'CANCELED' },
			org_todo_keyword_faces = {
				NEXT = ':foreground #ffffff :background #5555ff',
				PROGRESS = ':foreground #cccc22 :background #444444',
				CANCELED = ':foreground #aaaaaa :background #333333',
			},

			-- Appearance
			win_border = 'rounded',
			org_hide_emphasis_markers = true,

			-- Note files
			org_agenda_files = MYPATHS.org .. '/**/*.org',
			org_default_notes_file = MYPATHS.org .. '/agenda/main.org',

			-- Custom captures. See https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org_capture_templates
			org_capture_templates = {},
		},
	},
	{
		'nvim-orgmode/telescope-orgmode.nvim',

		dependencies = {
			'nvim-orgmode/orgmode',
			'nvim-telescope/telescope.nvim',
		},

		keys = {
			{
				'<leader>ohr',
				function()
					require('telescope').extensions.orgmode.refile_heading()
				end,
				desc = 'Refile a heading with Telescope',
			},
			{
				'<leader>os',
				function()
					require('telescope').extensions.orgmode.search_headings()
				end,
				desc = 'Search a heading or org file (C-Space to switch between them)',
			},
			{
				'<leader>oil',
				function()
					require('telescope').extensions.orgmode.insert_link()
				end,
				desc = 'Insert a link (C-Space to switch between headline or orgfile)',
			},
		},

		init = function()
			MYPLUGFUNC.load_telescope_extension('orgmode', { 'refile_heading', 'search_headings', 'insert_link' })
		end,
	},
	{
		'chipsenkbeil/org-roam.nvim',
		dependencies = {
			'nvim-orgmode/orgmode',
		},

		ft = 'org',
		keys = {
			{ '<leader>O', desc = 'org-roam key mappings' },
		},

		opts = {
			bindings = {
				prefix = '<leader>O',
			},

			directory = MYPATHS.org .. '/notes',

			immediate = {
				-- Based in the configuration at https://github.com/chipsenkbeil/org-roam.nvim/blob/main/DOCS.org
				-- I just swap the slug and the date indicator
				target = '%[slug]-%<%Y%m%d%H%M%S>.org',
			},

			templates = {
				-- Use the same template from the default configuration, but changes the target. I just swap the slug and the date
				-- indicator. Based on the configuration at https://github.com/chipsenkbeil/org-roam.nvim/blob/main/DOCS.org
				d = {
					description = 'default',
					target = '%[slug]-%<%Y%m%d%H%M%S>.org',
				},
			},

			extensions = {
				dailies = {
					directory = MYPATHS.org .. '/journals',
				},
			},
		},
	},
}
