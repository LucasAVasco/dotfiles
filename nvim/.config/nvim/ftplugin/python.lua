MYFUNC.call_if_before_editor_config(function()
	vim.bo.textwidth = 88 -- Max line size as specified by E501 (https://docs.astral.sh/ruff/rules/line-too-long/)
end)
