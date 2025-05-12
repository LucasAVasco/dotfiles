---Get the file type of a file if it is a Helm chart file.
---@param path string File path.
---@return string? file_type 'helm' if the file is a Helm chart. None otherwise.
local function get_filetype(path)
	local helm_base_dir = MYFUNC.iter_path(path, function(dir)
		return vim.fn.filereadable(dir .. '/Chart.yaml') == 1
	end)

	if helm_base_dir then
		return 'helm'
	end
end

return {
	{
		'towolf/vim-helm',

		ft = 'helm',

		init = function()
			vim.filetype.add({
				filename = {
					['Chart.yaml'] = 'helm',
					['Chart.lock'] = 'helm',
				},

				pattern = {
					['helmfile.*.ya?ml'] = 'helm',
					['.*/templates/.*.ya?ml'] = get_filetype,
					['.*/templates/.*.tpl'] = get_filetype,
				},
			})
		end,

		config = function()
			-- This plugin is lazy loaded. It may not be able to set the syntax highlight of the first opened Helm file. Must reset the file
			-- type in order to fix this
			vim.api.nvim_create_autocmd('FileType', {
				pattern = 'helm',
				callback = function(event)
					local buffer_nr = event.buf

					vim.schedule(function()
						vim.bo[buffer_nr].filetype = 'helm'
					end)

					return true -- Runs this auto-command only once
				end,
			})
		end,
	},
}
