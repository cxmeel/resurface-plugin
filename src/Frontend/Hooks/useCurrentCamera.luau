local useState = require("@pkgs/React").useState
local useEvent = require("./useEvent")

local function useCurrentCamera()
	local camera, setCamera = useState(workspace.CurrentCamera)

	useEvent(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		if workspace.CurrentCamera then
			setCamera(workspace.CurrentCamera)
		end
	end)

	return camera
end

return useCurrentCamera
