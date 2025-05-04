return {
	{
		'rachartier/tiny-inline-diagnostic.nvim',
		event = 'DiagnosticChanged',

		opts = {
			preset = 'modern',

			options = {
				-- Shows diagnostic source.
				show_source = {
					enabled = true,
					if_many = false, -- Only shows the source if there are many sources
				},

				throttle = 100, -- Update time of diagnostic pop-up in milliseconds

				-- Multi-line diagnostics (shows a diagnostics pop-up even if the cursor is not on the line) {{{

				add_messages = false, -- Shows messages on multi-line diagnostics

				multilines = {
					enabled = true,
					always_show = true,
				},

				-- }}}

				--- Wrapping long messages {{{

				-- If the message length is lower that this number of bytes, puts it below the cursor. Otherwise, puts at the end of line
				softwrap = 0,

				overflow = {
					mode = 'wrap',
					padding = 5, -- Padding at the right of the diagnostic. Requires `mode = "wrap"`
				},

				--- }}}

				overwrite_events = {
					-- Default  events
					'LspAttach',

					-- Events that I want to track
					'DiagnosticChanged', -- Required by my lazy loading setup
				},
			},

			disabled_ft = {},
		},

		init = function()
			vim.diagnostic.config({ virtual_text = false })
		end,

		config = function(_, opts)
			local tiny_inline_diagnostic = require('tiny-inline-diagnostic')
			tiny_inline_diagnostic.setup(opts)

			-- My lazy loading configuration requires to reset all diagnostics in order to setup 'tiny-inline-diagnostic' auto-commands
			MYFUNC.reset_diagnostics()
		end,
	},
}
