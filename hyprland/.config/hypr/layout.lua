---@alias HyprlandLayout "dwindle" | "master" | "scrolling" | "monocle"

---@type HyprlandLayout[]
local layouts = { "dwindle", "master", "scrolling", "monocle" }

local M = {}

---Returns layout of the current workspace
---@return HyprlandLayout name Name of the layout
---@return string? error Error message on failure
local function get_current_layout()
	local workspace = hl.get_active_workspace()
	if workspace == nil then
		return layouts[1], "workspace not found"
	end

	return workspace.tiled_layout
end

---Returns index of the current layout
---@return number
---@return string? error Error message on failure
local function get_current_layout_index()
	local layout, err = get_current_layout()
	if err ~= nil then
		return 1, "error getting current layout: " .. err
	end

	for i, l in ipairs(layouts) do
		if l == layout then
			return i
		end
	end

	return 1, ("the current layout '%s' is not in the list of layouts"):format(layout)
end

---Sets layout of the current workspace
---@param layout HyprlandLayout
local function set_layout(layout)
	local workspace = hl.get_active_workspace()
	if workspace == nil then
		return "workspace not found"
	end

	hl.workspace_rule({ workspace = workspace.name, layout = layout })
end

---Sets the layout of the current workspace
---@param index number Index of the layout to set
---@return string? error Error message on failure
local function set_layout_by_index(index)
	if index > #layouts or index < 1 then
		return "invalid layout index: " .. index
	end

	local err = set_layout(layouts[index])
	if err ~= nil then
		return "error setting layout: " .. err
	end
end

---Returns layout of the current workspace
---@return HyprlandLayout
function M.get_current()
	return get_current_layout()
end

---Sets the layout of the current workspace
---@param layout HyprlandLayout
function M.set(layout)
	local err = set_layout(layout)
	error("error setting layout: " .. err, 2)
end

---Cycles to the next layout
function M.next()
	local index = (get_current_layout_index() % #layouts) + 1

	local err = set_layout_by_index(index)
	if err ~= nil then
		error("error setting layout by index: " .. err, 2)
	end
end

---Cycles to the previous layout
function M.previous()
	local index = get_current_layout_index() - 1
	if index < 1 then
		index = #layouts
	end

	local err = set_layout_by_index(index)
	if err ~= nil then
		error("error setting layout by index: " .. err, 2)
	end
end

return M
