vim.filetype.add({
	filename = {
		['user-data'] = 'yaml',
	},

	pattern = {
		['.env.*'] = 'sh',
	},

	extension = {
		['cheat'] = 'cfg',
		['vifm'] = 'vim',
		['alloy'] = 'hcl',
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
		-- Helm
		['.*/templates/.*.ya?ml'] = is_helm_template_file,
		['.*/templates/.*.tm?pl'] = is_helm_template_file,
		['.*/templates/.*.gotmpl'] = is_helm_template_file,

		-- Helmfile
		['helmfile.*.ya?ml(.gotmpl)'] = 'helm',
		['.*/helmfile.d/.*.ya?ml(.gotmpl)'] = 'helm',
	},
})
