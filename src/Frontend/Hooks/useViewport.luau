local useState = require("@pkgs/React").useState
local useCurrentCamera = require("./useCurrentCamera")
local useEvent = require("./useEvent")

local function useViewport()
	local camera = useCurrentCamera()
	local viewport, setViewport = useState(camera.ViewportSize)

	useEvent(camera:GetPropertyChangedSignal("ViewportSize"), function()
		setViewport(camera.ViewportSize)
	end)

	return viewport
end

return useViewport
