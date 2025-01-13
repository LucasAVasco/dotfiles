-- Will enable 24-bit RGB color in the TUI for these terminals (queried from $TERM)
local terminals_with_termguicolors = { 'alacritty', 'tmux-256color' }

for _, terminal in ipairs(terminals_with_termguicolors) do
	if vim.env.TERM == terminal or vim.env.TERM == 'tmux-' .. terminal then
		vim.opt.termguicolors = true
	end
end
