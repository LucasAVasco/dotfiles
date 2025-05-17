-- INFO(LucasAVasco): I just copied the example configuration at 'https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md' and
-- tweaked it to my liking

---@module 'snacks'
---@type snacks.dashboard.Config|{}
return {
	sections = {
		{ section = 'header' },
		{
			pane = 2,
			section = 'terminal',
			cmd = 'shell-color-script -e fade',
			height = 5,
			padding = 1,
		},

		-- Second section
		{
			gap = 1,
			padding = 1,
			section = 'keys',
		},
		{
			icon = ' ',
			indent = 2,
			padding = 2,
			pane = 2,
			section = 'recent_files',
			title = 'Recent Files',
		},
		{
			icon = ' ',
			indent = 2,
			padding = 2,
			pane = 2,
			section = 'projects',
			title = 'Projects',
		},
		{
			cmd = 'git status . --short --branch',
			height = 10,
			icon = ' ',
			indent = 2,
			padding = 1,
			pane = 2,
			section = 'terminal',
			title = 'Git Status',
			ttl = 5 * 60,
			enabled = function()
				return require('snacks').git.get_root() ~= nil
			end,
		},

		-- Last section
		{ section = 'startup' },
	},

	preset = {
		keys = {
			{ icon = ' ', key = 'n', desc = 'New File', action = ':enew | only' },
			{ icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
			{ icon = ' ', key = 't', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
			{ icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
			{ icon = ' ', key = 'e', desc = 'File explorer', action = ':NvimTreeFocus' },
			{ icon = '󰖌 ', key = 'o', desc = 'Oil', action = ':Oil' },
			{ icon = ' ', key = 'g', desc = 'Git UI', action = ':Git | only' },
			{ icon = ' ', key = 'G', desc = 'Lazy Git', action = ':Lazygit' },
			{ icon = '󰆼 ', key = 'd', desc = 'Database UI', action = ':ene | DBUI' },
			{ icon = '󱃆 ', key = 'p', desc = 'List NOPUSH comments', action = ':TodoTelescope keywords=NOPUSH' },
			{ icon = ' ', key = 's', desc = 'Restore Session', section = 'session' },
			{ icon = ' ', key = 'k', desc = 'Check key maps', action = ':Lazy load all | checkhealth which-key' },
			{ icon = '󰸟 ', key = 'h', desc = 'Healthchecks', action = ':Lazy load all | checkhealth' },
			{ icon = '󰒲 ', key = 'L', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
			{ icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
		},
	},
}
