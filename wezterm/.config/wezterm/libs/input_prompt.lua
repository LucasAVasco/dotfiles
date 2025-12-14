local M = {}

---String used to identify the left prompt. The left prompt MUST be the unique prompt containing this string. All the other prompts MUST not
---contain this string
local unique_left_prompt_content = ''

---@class (exact) SemanticZone
---@field semantic_type 'Input' | 'Output' | 'Prompt'
---@field start_x integer
---@field start_y integer
---@field end_x integer
---@field end_y integer

---Get the content of the last semantic zone of the specified type.
---@param pane any
---@param zone SemanticZone
---@return string
local function get_text_from_zone(pane, zone)
	zone.end_y = zone.end_y + 1 -- For some reason, if we don't do this, the last line is not included
	return pane:get_text_from_semantic_zone(zone)
end

local function zone_is_left_prompt(pane, zone)
	if zone.semantic_type ~= 'Prompt' then
		return false
	end

	local text = get_text_from_zone(pane, zone)
	return text:find(unique_left_prompt_content, 0, true)
end

---Get the content of the current and last inputs
---@param pane any
---@return string current_input, string last_input The current input and the last input content
function M.get_current_and_last_inputs(pane)
	---@type SemanticZone[]
	local zones = pane:get_semantic_zones()
	if #zones <= 0 then
		return '', ''
	end

	if zones == nil then
		return '', ''
	end

	-- Text of the last input
	local current_input = ''
	local last_input = ''

	-- Index of the zone of the last input
	local i = #zones

	-- Extracts all inputs until the next left prompt
	while i > 0 do
		local zone = zones[i]
		if zone.semantic_type == 'Input' then
			current_input = get_text_from_zone(pane, zone) .. current_input
		elseif zone_is_left_prompt(pane, zone) then
			break
		end

		i = i - 1
	end

	-- Ignores the prompt
	if i > 0 then
		i = i - 1
	end

	-- Last input
	while i > 0 do
		local zone = zones[i]
		if zone.semantic_type == 'Input' then
			last_input = get_text_from_zone(pane, zone) .. last_input
		elseif zone_is_left_prompt(pane, zone) then
			break
		end

		i = i - 1
	end

	return current_input, last_input
end

return M
