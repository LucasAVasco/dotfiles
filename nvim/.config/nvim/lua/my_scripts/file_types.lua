vim.filetype.add({
	pattern = {
		['.env.*'] = 'sh',
	},
	extension = {
		['cheat'] = 'cfg',
		['vifm'] = 'vim',
	},
})

---Filetype function that checks if the file is a Helm related file.
---@param path string File path.
---@return string? file_type 'helm' if the file is a Helm related file. None otherwise.
local function is_helm_template_file(path)
	local helm_base_dir = MYFUNC.iter_path(path, function(dir)
		return vim.fn.filereadable(dir .. '/Chart.yaml') == 1
	end)

	if helm_base_dir then
		return 'helm'
	end
end

vim.filetype.add({
	filename = {
		['Chart.yaml'] = 'helm',
		['Chart.lock'] = 'helm',
	},

	pattern = {
		['helmfile.*.ya?ml(.gotmpl)'] = 'helm',
		['.*/templates/.*.ya?ml'] = is_helm_template_file,
		['.*/templates/.*.tpl'] = is_helm_template_file,
	},
})
