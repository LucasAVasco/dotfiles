--[[
	Snippets to place ANSI escape colors
]]

local ls = require('luasnip')
local sn = ls.snippet_node
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node

-- Escapes sequences used to apply the ANSI escape color
local escapes = {
	octal = '\\033',
	hex = '\\x1b',
	unicode = '\\u001b',
}

-- Base number of foreground and background colors. Foreground colors starts at number 30 and so on
local grounds = {
	fg = 30,
	bg = 40,
	brightfg = 90,
	brightbg = 100,
}

-- Some useful terminal modifiers. Follows the ANSI escape modifiers order. Not all terminals support all these modifiers
local modifiers = {
	normal = 0,
	bold = 1,
	faint = 2,
	italic = 3,
	underline = 4,
	blink = 5,
	fastblink = 6,
	reverse = 7,
	hide = 8,
	strike = 9,
}

-- Color index to sum to the ground base number
local colors = {
	black = 0,
	red = 1,
	green = 2,
	yellow = 3,
	blue = 4,
	magenta = 5,
	cyan = 6,
	white = 7,
}

---Create a choice snippet with the provided elements.
---Each element will be converted in a text node.
---@param index number Index of the choice node in the snippet
---@param choices table<string, any> Choices to be converted in the choice script
---@return any choice_node
local function create_choice_snippet(index, choices)
	local content = {}

	for key, _ in pairs(choices) do
		table.insert(content, t(key))
	end

	return c(index, content)
end

---Replace the generated ANSI color identifier by the ANSI color escape.
---@param parent any parent node of the current function node
---@return string escape_color
local function replace_ansi_snippet(_, parent, _)
	local escape = parent.captures[1]
	local ground = parent.captures[2]
	local color = parent.captures[3]
	local mod = parent.captures[4]

	return ('%s[%s;%sm'):format(escapes[escape], modifiers[mod], grounds[ground] + colors[color])
end

---Replace the generated ANSI reset color identifier by the ANSI color escape
---@param parent any parent node of the current function node
---@return string escape_color
local function replace_ansi_reset_snippet(_, parent, _)
	local escape = parent.captures[1]

	return ('%s[0m'):format(escapes[escape])
end

return {
	-- Insert a ANSI color escape
	s({
		trig = 'ansi-color-identifier',
		name = 'ANSI color identifier.',
		desc = 'Create a identifier that can be exanded (as any other snippet) to a ANSI color escape sequence.',
	}, {
		d(1, function() -- Use a dynamic node to avoid create all choice snippets at the startup
			return sn(nil, {
				t('<<ansi-color-'),
				create_choice_snippet(1, escapes),
				t('-'),
				create_choice_snippet(2, grounds),
				t('-'),
				create_choice_snippet(3, colors),
				t('-'),
				create_choice_snippet(4, modifiers),
				t('>>'),
			})
		end, {}),
	}),
	s({
		trigEngine = 'pattern',
		trig = '<<ansi%-color%-(%l+)%-(%l+)%-(%l+)%-(%l+)>>',
		hidden = true,
		name = 'ANSI color identifier to ANSI color escape.',
		desc = 'Exapand the current ANSI color identifier to its respective ANSI color escape sequence.',
	}, {
		f(replace_ansi_snippet, {}),
	}),

	-- Insert a ANSI reset color escape
	s({
		trig = 'ansi-reset-color',
		name = 'Reset ANSI color.',
		desc = 'Create a identifier that can be exanded (as any other snippet) to a ANSI reset color escape sequence.',
	}, {
		d(1, function() -- Use a dynamic node to avoid create all choice snippets at the startup
			return sn(nil, {
				t('<<ansi-reset-color-'),
				create_choice_snippet(1, escapes),
				t('>>'),
			})
		end, {}),
	}),
	s({
		trigEngine = 'pattern',
		trig = '<<ansi%-reset%-color%-(%l+)>>',
		hidden = true,
		name = 'ANSI reset color identifier to ANSI reset color escape.',
		desc = 'Exapand the current ANSI reset color identifier to its respective ANSI reset color escape sequence.',
	}, {
		f(replace_ansi_reset_snippet, {}),
	}),
}
