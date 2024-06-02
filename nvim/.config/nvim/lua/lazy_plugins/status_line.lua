return {
	{
		'vim-airline/vim-airline',

		dependencies = {
			'vim-airline/vim-airline-themes'
		},

		init = function()
			vim.g['airline#extensions#tabline#enabled'] = 1  -- Line on top with tabs

			vim.g.airline_left_sep = ''
			vim.g.airline_right_sep = ''
			vim.g.airline_left_alt_sep = ''
			vim.g.airline_right_alt_sep = ''

			vim.g['airline#extensions#tabline#left_sep'] = ' '
			vim.g['airline#extensions#tabline#right_sep'] = ' '
			vim.g['airline#extensions#tabline#left_alt_sep'] = '┃'
			vim.g['airline#extensions#tabline#right_alt_sep'] = ' '

			-- Themes
			vim.g.airline_theme = 'base16_gruvbox_dark_pale'
		end
	}
}
