--[[ autodoc
	====================================================================================================
	DAP commands (Plugin)[cmd]                                                     *plugin-DAP-commands*

	`DapLoadLaunchJSON`: Load the 'launch.json' file
	`DapEditLaunchFile`: Edit the 'launch.json' file

	====================================================================================================
	DAP information (Plugin)[info]                                                     *plugin-DAP-info*

	Adapter configuration: |dap-adapter|
	`launch.json` configuration: |dap-launch.json|
]]

---@type MyFunctionKeysMappings
local dap_fkeys = {
	shift = {}, -- Fulfilled at `nvim-dap` configuration
	normal = {}, -- Fulfilled at `nvim-dap` configuration
}

---Toggle a DAP breakpoint in the current cursor position
local function toggle_breakpoint()
	require('dap').toggle_breakpoint()
end

---Configure the function key mappings to manage the current DAP session.
---The key mappings setup is at `nvim-dap` configuration function.
local function set_dap_fkeys()
	require('dap') -- The `dap_fkeys` variable is fulfilled at `nvim-dap` configuration function
	MYFUNC.set_fkey_mappings(dap_fkeys)
end

return {
	{
		'mfussenegger/nvim-dap',

		cmd = {
			'DapStepInto',
			'DapShowLog',
			'DapStepOut',
			'DapTerminate',
			'DapStepOver',
			'DapToggleBreakpoint',
			'DapSetLogLevel',
			'DapNew',
			'DapDisconnect',
			'DapRestartFrame',
			'DapEval',
			'DapLoadLaunchJSON',
			'DapToggleRepl',

			-- My user commands (not a `nvim-dap` default)
			'DapEditLaunchJSON',
		},

		keys = {
			-- Session management {{{
			{
				'<leader>Dc',
				function()
					require('dap').continue()
				end,
				desc = 'Continue (DAP)',
			},
			{
				'<leader>DC',
				function()
					require('dap').reverse_continue()
				end,
				desc = 'Reverse continue (DAP)',
			},
			{
				'<leader>Dp',
				function()
					require('dap').pause()
				end,
				desc = 'Pause (DAP)',
			},
			{
				'<leader>Drc',
				function()
					require('dap').run_to_cursor()
				end,
				desc = 'Run to cursor (DAP)',
			},
			{
				'<leader>Drl',
				function()
					require('dap').run_last()
				end,
				desc = 'Run last (DAP)',
			},
			{
				'<leader>Dt',
				function()
					require('dap').terminate()
				end,
				desc = 'Terminate (DAP)',
			},
			-- }}}
			-- Breakpoints {{{
			{
				'<leader>b',
				toggle_breakpoint,
				desc = 'Toggle breakpoint (DAP)',
			},
			{
				'<leader>Dbb',
				toggle_breakpoint,
				desc = 'Toggle breakpoint (DAP)',
			},
			{
				'<leader>Dbl',
				function()
					vim.ui.input({
						prompt = 'Log message:',
					}, function(log_message)
						if log_message then
							require('dap').set_breakpoint(nil, nil, log_message)
						end
					end)
				end,
				desc = 'Set logpoint (DAP)',
			},
			{
				'<leader>Dbf',
				function()
					vim.ui.input({
						prompt = 'Condition:',
					}, function(condition)
						vim.ui.input({
							prompt = 'Hint condition:',
						}, function(hint_condition)
							vim.ui.input({
								prompt = 'Log message:',
							}, function(log_message)
								require('dap').set_breakpoint(condition, hint_condition, log_message)
							end)
						end)
					end)
				end,
				desc = 'Set breakpoint with full features (DAP)',
			},
			{
				'<leader>Dbc',
				function()
					require('dap').clear_breakpoints()
				end,
				desc = 'Clear all breakpoints (DAP)',
			},
			-- }}}
			-- Frames {{{
			{
				'<leader>Dff',
				function()
					require('dap').focus_frame()
				end,
				desc = 'Focus the frame (DAP)',
			},
			{
				'<leader>Dfr',
				function()
					require('dap').restart_frame()
				end,
				desc = 'Restart frame (DAP)',
			},
			-- }}}
			{
				'<leader>Dg',
				function()
					require('dap').goto_()
				end,
				desc = 'Jump to cursor line (DAP)',
			},
			{
				'<leader>Dh',
				function()
					require('dap.ui.widgets').hover()
				end,
				desc = 'Hover (DAP)',
			},
			{
				'<leader>Dk',
				set_dap_fkeys,
				desc = 'Set DAP function keys mappings',
			},
		},

		init = function()
			MYPLUGFUNC.set_keymap_name('<leader>D', 'Debugger Adapter Protocol')
		end,

		config = function()
			local dap = require('dap')

			-- Fulfills the function keys mappings. The order is based in the `nvim-dap-ui` interface

			dap_fkeys.shift = { dap.pause, dap.step_out, dap.step_back, dap.down, dap.disconnect }
			dap_fkeys.normal = { dap.continue, dap.step_into, dap.step_over, dap.up, dap.restart }

			-- Configure `dap.adapters` table to automatically query the adapters configuration from the 'lua/my_configs/DAP/' folders
			-- inside any runtime directory at `vim.opt.rtp`

			setmetatable(dap.adapters, {
				__index = function(_, adapter_type)
					return require('my_configs.DAP.' .. adapter_type)
				end,
			})

			-- Loads debug configurations from a Json file like VS Code

			local project_dir = require('project_runtime_dirs.api.project').get_project_directory() or vim.fn.getcwd()
			local launchjs_file = project_dir .. '.nvim_dap_launch.json'
			local dap2filetype = {}

			local nc = require('noi' .. 'ce') -- Separates the module name because `typos_lsp` throws an error

			-- This plugin can not execute `vim.fn.confirm()` inside a configuration function. It does not show anything. Disables this
			-- plugin and use the default `vim.fn.confirm()` function in the configuration function
			local deactivate_nc = true

			local function load_launchjs()
				if vim.fn.filereadable(launchjs_file) == 0 then
					return
				end

				if deactivate_nc then
					nc.deactivate()
				end

				local data = vim.secure.read(launchjs_file)

				if deactivate_nc then
					nc.enable()
				end

				if data then
					require('dap.ext.vscode').load_launchjs(launchjs_file, dap2filetype)
				end
			end

			load_launchjs()
			deactivate_nc = false -- Only need to deactivate in a configuration function (not required to user commands)

			-- Overrides the `dap.nvim` command to load my `launch.json` file
			vim.api.nvim_create_user_command('DapLoadLaunchJSON', function()
				load_launchjs()
			end, {})

			-- User command to edit the my `launch.json` file
			vim.api.nvim_create_user_command('DapEditLaunchJSON', function()
				vim.cmd.edit({ args = { launchjs_file }, magic = { file = false, bar = false } })
			end, {})

			-- Sign column

			vim.fn.sign_define('DapBreakpoint', {
				text = '',
				texthl = 'DiagnosticSignWarn',
			})

			vim.fn.sign_define('DapBreakpointCondition', {
				text = '',
				texthl = 'DiagnosticSignWarn',
			})

			vim.fn.sign_define('DapLogPoint', {
				text = '',
				texthl = 'DiagnosticSignInfo',
			})

			vim.fn.sign_define('DapStopped', {
				text = '',
				texthl = 'DiagnosticSignOk',
			})

			vim.fn.sign_define('DapBreakpointRejected', {
				text = '',
				texthl = 'DiagnosticSignError',
			})

			-- Load `nvim-dap-virtual-text`
			require('nvim-dap-virtual-text')
		end,
	},
	{
		'theHamsta/nvim-dap-virtual-text',

		dependencies = {
			'mfussenegger/nvim-dap',
			'nvim-treesitter/nvim-treesitter',
		},

		lazy = true,

		---@module 'nvim-dap-virtual-text'
		---@class nvim_dap_virtual_text_options
		opts = {
			---@module 'dap'
			---@param variable Variable Information about the variable
			---@param bufnr number Number of the virtual text buffer
			---@param stack_frame dap.StackFrame Source location
			---@param ts_node userdata Tree-sitter node of the variable
			---@param opts nvim_dap_virtual_text_options Plugin options
			---@return string? string Text to be placed at the virtual text
			---@diagnostic disable-next-line: unused-local
			display_callback = function(variable, bufnr, stack_frame, ts_node, opts)
				---@type string
				local res = ''

				-- name
				if opts.virt_text_pos == 'eol' then
					res = ' ' .. variable.name .. ': '
				elseif opts.virt_text_pos == 'inline' then
					res = ' 󰙎: '
				else
					vim.notify('Unrecognized virtual text position: ' .. opts.virt_text_pos)
				end

				-- Value
				res = res .. variable.value

				-- Removes sequential spaces
				res = res:gsub('%s+', ' ')

				-- Max length
				if #res > 30 then
					res = res:sub(0, 29) .. '…'
				end

				return res
			end,
		},
	},
	{
		'rcarriga/nvim-dap-ui',
		dependencies = {
			'mfussenegger/nvim-dap',
			'nvim-neotest/nvim-nio',
		},

		cmd = { 'DapOpenUi', 'DapCloseUi', 'DapToggleUi' },

		keys = {
			{
				'<leader>DU',
				function()
					set_dap_fkeys()
					require('dapui').toggle()
				end,
				desc = 'Toggle DAP UI',
			},
		},

		config = function(_, opts)
			local dapui = require('dapui')
			dapui.setup(opts)

			vim.api.nvim_create_user_command('DapOpenUi', function()
				set_dap_fkeys()
				dapui.open()
			end, {})
			vim.api.nvim_create_user_command('DapCloseUi', function()
				dapui.close()
			end, {})
			vim.api.nvim_create_user_command('DapToggleUi', function()
				set_dap_fkeys()
				dapui.toggle()
			end, {})
		end,
	},
}
