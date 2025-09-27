local wezterm = require('wezterm')
local action = wezterm.action
local keys = {}

-- Constants {{{

local NONE = 'NONE'
local LEADER <const> = 'LEADER'
-- local LEADER_CTRL <const> = 'LEADER|CTRL'
local CTRL <const> = 'CTRL'
local ALT <const> = 'ALT'
-- local ALT_SHIFT <const> = 'ALT|SHIFT'
local CTRL_SHIFT <const> = 'CTRL|SHIFT'
local CTRL_ALT <const> = 'CTRL|ALT'
local CTRL_ALT_SHIFT <const> = 'CTRL|ALT|SHIFT'
local SHIFT <const> = 'SHIFT'
local DEFAULT_KEY_BINDS_OPTIONS <const> = {
	domain = 'CurrentPaneDomain',
}

local DIRECTIONS <const> = { 'Left', 'Down', 'Up', 'Right' }
-- local DIRECTIONS_ARROWS <const> = { 'LeftArrow', 'DownArrow', 'UpArrow', 'RightArrow' }
local DIRECTIONS_HJKL <const> = { 'h', 'j', 'k', 'l' }

-- }}}

---Get a action that jumps to the specified direction and activates the 'jump_pane' key table.
---@param direction direction Direction of the initial jump.
---@return any
local function get_jump_pane_action(direction)
	return action.Multiple({
		action.ActivatePaneDirection(direction),

		action.ActivateKeyTable({
			name = 'jump_pane',
			one_shot = false,
		}),
	})
end

---@class (exact) KeyBind
---@field key string Key that triggers the action
---@field mods string Modifies the key that triggers the action
---@field action any Action triggered by the key bind

---@type KeyBind[]
---List of keybinds: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
---Key table documentation: https://wezfurlong.org/wezterm/config/key-tables.html
---Quick Select with custom arguments: https://wezfurlong.org/wezterm/config/lua/keyassignment/QuickSelectArgs.html
keys = {
	-- Tab, pane creation and deletion
	{
		key = 'c',
		mods = LEADER,
		action = action.SpawnTab('CurrentPaneDomain'),
	},
	{
		key = 'q',
		mods = LEADER,
		action = action.SpawnTab('CurrentPaneDomain'),
	},
	{
		key = 't',
		mods = LEADER,
		action = action.SpawnTab('CurrentPaneDomain'),
	},
	{
		key = 'w',
		mods = LEADER,
		action = action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = 'W',
		mods = LEADER,
		action = action.CloseCurrentTab({ confirm = true }),
	},
	-- Splits
	{
		key = '-',
		mods = LEADER,
		action = action.SplitVertical(DEFAULT_KEY_BINDS_OPTIONS),
	},
	{
		key = '=',
		mods = LEADER,
		action = action.SplitHorizontal(DEFAULT_KEY_BINDS_OPTIONS),
	},
	-- Zoom
	{
		key = 'z',
		mods = LEADER,
		action = action.TogglePaneZoomState,
	},
	-- Tab, window and, pane selection
	{
		key = 'Space',
		mods = LEADER,
		action = action.PaneSelect({
			mode = 'SwapWithActive',
		}),
	},
	{
		key = '[',
		mods = LEADER,
		action = action.ActivateTabRelativeNoWrap(-1),
	},
	{
		key = ']',
		mods = LEADER,
		action = action.ActivateTabRelativeNoWrap(1),
	},
	-- Scroll
	{
		key = '[',
		mods = CTRL_ALT,
		action = action.ScrollByPage(-0.5),
	},
	{
		key = ']',
		mods = CTRL_ALT,
		action = action.ScrollByPage(0.5),
	},
	{ key = '{', mods = CTRL_ALT, action = action.ScrollToPrompt(-1) },
	{ key = '}', mods = CTRL_ALT, action = action.ScrollToPrompt(1) },
	{ key = '[', mods = CTRL_ALT_SHIFT, action = action.ScrollToPrompt(-1) }, -- Keyboards that '{' is equivalent to '<SHIFT-[>'
	{ key = ']', mods = CTRL_ALT_SHIFT, action = action.ScrollToPrompt(1) },
	{ key = '{', mods = CTRL_ALT_SHIFT, action = action.ScrollToPrompt(-1) }, -- Keyboards that '{' is equivalent to '<SHIFT-[>'
	{ key = '}', mods = CTRL_ALT_SHIFT, action = action.ScrollToPrompt(1) },
	-- Copy mode
	{
		key = 'v',
		mods = LEADER,
		action = action.ActivateCopyMode,
	},
	-- Quick select
	{
		key = 'f',
		mods = LEADER,
		action = action.QuickSelect,
	},
	-- Copy Unicode character to clipboard
	{
		key = 'u',
		mods = LEADER,
		action = action.CharSelect({ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' }),
	},
	-- Command palette
	{
		key = ':',
		mods = LEADER,
		action = action.ActivateCommandPalette,
	},
	{
		key = ';',
		mods = LEADER,
		action = action.ActivateCommandPalette,
	},
	-- Key tables
	{
		key = 'Escape',
		mods = LEADER,
		action = action.ClearKeyTableStack,
	},
	{
		key = 'r',
		mods = LEADER,
		action = action.ActivateKeyTable({
			name = 'resize_pane',
			one_shot = false,
		}),
	},
	{
		key = 'm',
		mods = LEADER,
		action = action.ActivateKeyTable({
			name = 'move_tab',
			timeout_milliseconds = 2000,
		}),
	},
	{
		key = 'h',
		mods = LEADER,
		action = get_jump_pane_action('Left'),
	},
	{
		key = 'j',
		mods = LEADER,
		action = get_jump_pane_action('Down'),
	},
	{
		key = 'k',
		mods = LEADER,
		action = get_jump_pane_action('Up'),
	},
	{
		key = 'l',
		mods = LEADER,
		action = get_jump_pane_action('Right'),
	},
	-- Search mode
	{
		key = 's',
		mods = LEADER,
		action = action.Search('CurrentSelectionOrEmptyString'),
	},
	{
		key = '/',
		mods = LEADER,
		action = action.Search('CurrentSelectionOrEmptyString'),
	},
	-- CTRL-Backspace is equivalent to CTRL-w
	{
		key = 'Backspace',
		mods = CTRL,
		action = action.SendKey({ key = 'w', mods = 'CTRL' }),
	},
	-- Disable some key binds
	{
		key = 'Enter',
		mods = ALT,
		action = action.DisableDefaultAssignment,
	},
	{
		key = 'w',
		mods = CTRL_SHIFT,
		action = action.DisableDefaultAssignment,
	},
	{
		key = 'Tab',
		mods = CTRL,
		action = action.DisableDefaultAssignment,
	},
}

-- Activate tabs
local tab_indexes = { '1', '2', '3', '4', '5', 'F1', 'F2', 'F3', 'F4', 'F5' }
for i, key in pairs(tab_indexes) do
	table.insert(keys, {
		key = key,
		mods = LEADER,
		action = action.ActivateTab(i - 1),
	})
end

--- Key tables {{{

---@type table<string, KeyBind[]>
local key_tables = {
	resize_pane = {
		{ key = 'Escape', mods = NONE, action = 'PopKeyTable' },
	},
	jump_pane = {
		{ key = 'Escape', mods = NONE, action = 'PopKeyTable' },
	},
	move_tab = {
		{ key = 'Escape', mods = NONE, action = 'PopKeyTable' },
	},
	copy_mode = {
		-- Move with `<A-u>` and `<A-d>` instead of `<C-u>` and `<C-d>`
		{
			key = 'u',
			mods = ALT,
			action = action.CopyMode({ MoveByPage = -0.5 }),
		},
		{
			key = 'd',
			mods = ALT,
			action = action.CopyMode({ MoveByPage = 0.5 }),
		},
		-- Searched pattern
		{
			key = 'f',
			mods = ALT,
			action = action.CopyMode('EditPattern'),
		},
		{
			key = '/',
			mods = NONE,
			action = action.CopyMode('EditPattern'),
		},
		{
			key = 's',
			mods = NONE,
			action = action.CopyMode({ SetSelectionMode = 'SemanticZone' }),
		},
	},
}

-- Jump to pane
for i in pairs(DIRECTIONS) do
	---@type KeyBind
	local key_bind = {
		key = DIRECTIONS_HJKL[i],
		mods = NONE,
		action = action.ActivatePaneDirection(DIRECTIONS[i]),
	}

	table.insert(key_tables.jump_pane, key_bind)
end

-- Move tab to another index
for i, key in pairs(tab_indexes) do
	---@type KeyBind
	local key_bind = {
		key = key,
		mods = NONE,
		action = action.MoveTab(i - 1),
	}

	table.insert(key_tables.move_tab, key_bind)
end

-- Adjust panel size
for i in pairs(DIRECTIONS) do
	---@type KeyBind
	local key_bind = {
		key = DIRECTIONS_HJKL[i],
		mods = NONE,
		action = action.AdjustPaneSize({ DIRECTIONS[i], 1 }),
	}

	---@type KeyBind
	local key_bind_long = {
		key = DIRECTIONS_HJKL[i],
		mods = SHIFT,
		action = action.AdjustPaneSize({ DIRECTIONS[i], 10 }),
	}

	---@type KeyBind
	local key_bind_move = {
		key = DIRECTIONS_HJKL[i],
		mods = CTRL,
		action = action.ActivatePaneDirection(DIRECTIONS[i]),
	}

	table.insert(key_tables.resize_pane, key_bind)
	table.insert(key_tables.resize_pane, key_bind_long)
	table.insert(key_tables.resize_pane, key_bind_move)
end

-- Merge the key tables with the default values

local default_key_tables = wezterm.gui.default_key_tables()
for _, key in pairs(default_key_tables.copy_mode) do
	table.insert(key_tables.copy_mode, key)
end

--- }}}

return {
	keys = keys,
	key_tables = key_tables,
}
