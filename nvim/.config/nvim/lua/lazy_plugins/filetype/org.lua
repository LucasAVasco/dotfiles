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
			org_todo_keywords = { 'TODO', 'NEXT', 'PROGRESS', '|', 'DONE' },
			org_todo_keyword_faces = {
				NEXT = ':foreground #ffffff :background #5555ff',
				PROGRESS = ':foreground #cccc22 :background #444444',
			},

			-- Appearance
			win_border = 'rounded',
			org_hide_emphasis_markers = true,

			-- Note files
			org_agenda_files = '~/Notes/**/*.org',
			org_default_notes_file = '~/Notes/main.org',

			-- Custom captures. See https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md#org_capture_templates
			org_capture_templates = {},
		},
	},
}
