-- Files configurations
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding ='utf-8'

-- Backup, undo and swap files
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.swapfile = true

local home_path = vim.env.HOME

vim.fn.system({'mkdir', '-p', home_path .. '/.nvim/.backup_files/', home_path .. '/.nvim/.undo_files/', home_path .. '/.nvim/.swap_files/'})
vim.opt.backupdir = home_path .. '/.nvim/.backup_files//'
vim.opt.undodir = home_path .. '/.nvim/.undo_files//'
vim.opt.directory = home_path .. '/.nvim/.swap_files//'

-- Mouse configurations
vim.opt.hidden = true
vim.opt.mouse = 'a'

-- Load the plugin files for specific file types
vim.cmd('filetype plugin on')

-- Load the indent file for specific file types
vim.cmd("filetype indent on")

-- Indentation
vim.opt.expandtab = false  -- Expand tabs to spaces convert tabs to spaces
vim.opt.smarttab = false   -- The smarttab option change how to use the 'tabstop', 'softtabstop' and 'shiftwidth'options
vim.opt.tabstop = 4        -- Number of spaces that a Tab represents
vim.opt.softtabstop = -1   -- Number of spaces added for Tab when editing ( <0 = use 'shiftwidth')
vim.opt.shiftwidth = 0     -- Number of spaces added for each indentation (0 = use 'tabstop')

-- Custom characters
local superspace_char = {'¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'}
local multispace_char = '𝅙⋅𝅙₀'       -- Spaces after any text
local lead_multispace_char = '𝅙⁰𝅙┋'  -- Spaces before any text

for i = 1, #superspace_char do
	multispace_char = multispace_char .. '𝅙⋅𝅙' .. superspace_char[i]
	lead_multispace_char = lead_multispace_char .. '𝅙' .. superspace_char[i] .. '𝅙┋'
end

vim.opt.list = true
vim.opt.listchars = 'tab:𝅙𝅙┋,leadmultispace:' .. lead_multispace_char .. ',multispace:' .. multispace_char
vim.opt.fillchars = 'foldopen:,foldclose:'
-- Alternative characters -> 󰇝┆┃󱋱╎⎜┇¦╏┇┋⸽┆┆┊󰇙⦚⸽⍿⟊⫯⫰¦‖⸾⸾⎸⋅⋯﴾﴿

-- Other configurations
vim.opt.updatetime = 400
vim.opt.signcolumn = "yes"     -- Colunm with symbols used by other tools like LSP, Git, etc.
vim.opt.number = true          -- Line number (if *relativenumber* is true, it is applied only to the current line)
vim.opt.relativenumber = true  -- Relative line number (applied only to lines other than the current)
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.scrolloff = 6          -- Minimum number of lines before and after the cursor
