local colors = {
	red = function(str)
		return `\27[31m{str}\27[39m`
	end,
	green = function(str)
		return `\27[32m{str}\27[39m`
	end,
	yellow = function(str)
		return `\27[33m{str}\27[39m`
	end,
	blue = function(str)
		return `\27[34m{str}\27[39m`
	end,
	grey = function(str)
		return `\27[90m{str}\27[39m`
	end,
	bold = function(str)
		return `\27[1m{str}\27[22m`
	end,
}

return colors
