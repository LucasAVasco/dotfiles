---Show a debug message
---@param text string
return function(text)
	hl.notification.create({
		text = text,
		duration = 3000, -- milliseconds
	})
end
