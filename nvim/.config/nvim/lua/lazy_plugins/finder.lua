return {
	{
		'nvim-telescope/telescope.nvim',

		dependencies = {
			'nvim-lua/plenary.nvim'
		},

		lazy = true,
		cmd = 'Telescope',

		config = function()
			local telescope = require('telescope')

			--- Open Telescope selection in Trouble
			--- @param ... Arguments provided by Telescope to `open()`
			local function open_with_trouble(...)
				require('trouble.sources.telescope').open(...)
			end

			--- Add Telescope selection to Trouble
			--- @param ... Arguments provided by Telescope to `add()`
			local function add_to_trouble(...)
				require('trouble.sources.telescope').add(...)
			end

			local tl_actions = require('telescope.actions')

			telescope.setup({
				defaults = {
					mappings = {
						n = {
							['<Esc>'] = false,  -- Disable <esc> because this can conflict with the normal mode
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['T'] = open_with_trouble,
							['t'] = add_to_trouble,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
						},
						i = {
							['<A-a>'] = tl_actions.close,
							['<A-q>'] = tl_actions.close,
							['<A-T>'] = open_with_trouble,
							['<A-t>'] = add_to_trouble,
						}
					}
				}
			})

			-- Load the 'nvim-notify' extension to show the notification history in Telescope
			telescope.load_extension('notify')
		end
	}
}
