local useMemo = require("@pkgs/React").useMemo
local useViewport = require("./useViewport")

local calculateDpiScale = require("../Lib/calculateDpiScale")

local function useDpiScale(fallback: number?)
	local viewport = useViewport()

	local dpiScale = useMemo(function()
		return calculateDpiScale(fallback)
	end, { viewport, fallback } :: { any })

	return dpiScale
end

return useDpiScale
