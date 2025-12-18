-- My local texmf/tex directory
local texmf_tex_dir = MYPATHS.home .. '/.texmf/tex/'

-- List of directories to add to `TEXINPUTS`, 'texlab' required it to find my local tex files
local dirs = vim.fn.glob(texmf_tex_dir .. '/**/', true, true)
table.insert(dirs, texmf_tex_dir)
table.insert(dirs, 1, '.')
table.insert(dirs, vim.env.TEXINPUTS)

---@module "my_configs.LSP.types"
---@type my_configs.LSP.LspServerConfig
return {
	cmd_env = {
		TEXINPUTS = table.concat(dirs, ':'),
	},
}
