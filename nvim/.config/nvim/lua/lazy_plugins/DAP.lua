--[[ autodoc
	====================================================================================================
	DAP commands (Plugin)[cmd]                                                     *plugin-DAP-commands*

	`DapEditProjectConfig`: Edit the 'nvim-dap' configuration file of the current project

	====================================================================================================
	DAP information (Plugin)[info]                                                     *plugin-DAP-info*

	Adapter configuration: |dap-adapter|
	Configuration file: |dap-configuration|
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
			'DapEditProjectConfig',
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

			-- Configure `dap.adapters` table to automatically query the adapters configuration from the 'lua/my_configs/DAP/adapters/'
			-- folders inside any runtime directory at `vim.opt.rtp`

			setmetatable(dap.adapters, {
				__index = function(_, adapter_type)
					return require('my_configs.DAP.configs.adapter.' .. adapter_type)
				end,
			})

			-- Configure `dap.configurations` table to automatically query the debugee configuration from the 'lua/my_configs/DAP/debugee/'
			-- folders inside any runtime directory at `vim.opt.rtp`

			local debugee = require('my_plugin_libs.DAP.debugee')
			setmetatable(dap.configurations, {
				__index = function(_, file_type)
					return debugee.get_file_configs(file_type)
				end,
			})

			-- User command to edit the my 'nvim-dap' configuration file
			vim.api.nvim_create_user_command('DapEditProjectConfig', function()
				-- Gets the configuration file
				local config_file = debugee.get_project_config_file()
				if not config_file then
					vim.notify(
						'Configuration file of current project does not exist! Maybe you are not in a project.',
						vim.log.levels.ERROR,
						{
							title = 'nvim-dap',
						}
					)
					return
				end

				-- Copies the default configuration file if it does not exist
				if vim.fn.filereadable(config_file) == 0 then
					local files = require('my_libs.fs.files')
					files.copy_file(MYPATHS.config .. '/lua/my_configs/DAP/default_DAP.lua', config_file)
				end

				-- Enables LazyDev, so the user can load use the types at '../my_configs/DAP/types.lua'
				vim.g.lazydev_enabled = true

				-- Edits the configuration file
				vim.cmd.edit({ args = { config_file }, magic = { file = false, bar = false } })
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
