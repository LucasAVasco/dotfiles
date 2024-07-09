return {
	{
		-- This plugin improves the text objects related to 'a' and 'i'. This is not plugin related to artificial intelligence
		'echasnovski/mini.ai',
		version = false,

		config = function()
			require('mini.ai').setup()
		end
	}
}
