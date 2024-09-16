local CoreGui = game:GetService("CoreGui")

local Janitor = require("@pkgs/Janitor")
local React = require("@pkgs/React")
local ReactRoblox = require("@pkgs/ReactRoblox")

local LocalStore = require("./Stores/LocalStore")
local Preferences = require("./Stores/Preferences")

-- Migrations to ease transition from Surface Tool
if plugin:GetSetting("currentVersion") ~= nil then
	LocalStore.isLegacyPluginTransition(true)
	Preferences.setMaterialToPlastic(false)
	Preferences.useMaterialVariants(false)
end

local App = require("./Frontend/App")

local janitor = Janitor.new()
local robloxCoreGui: ScreenGui? = CoreGui:FindFirstChild("RobloxGui")

local buildSessionId = script:GetAttribute("BuildSessionId")
	or script:GetAttribute("SourceCommitHash")
	or math.floor(tick() + 0.5)
buildSessionId = tostring(buildSessionId):sub(1, 7):lower()

local container = Instance.new("ScreenGui")
container.Name = `ResurfaceViewportWidget<{buildSessionId}>`
container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
container.IgnoreGuiInset = true
container.DisplayOrder = robloxCoreGui and robloxCoreGui.DisplayOrder + 100 or 1

local root = ReactRoblox.createRoot(container)
local app = React.createElement(App, {
	plugin = plugin,
})

local pluginActiveConnection = LocalStore.isPluginActive.changed:Connect(
	function(prevActive, isActive)
		if prevActive == isActive then
			return
		end

		if isActive then
			plugin:Activate(true)
		elseif plugin:IsActivated() then
			plugin:Deactivate()
		end
	end
)

local pluginDeactivationConnection = plugin.Deactivation:Connect(function()
	LocalStore.isPluginActive(false)
end)

local pluginUnloadingConnection = plugin.Unloading:Connect(function()
	if LocalStore.isPluginActive() or plugin:IsActivated() then
		plugin:Deactivate()
		plugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.new())
	end

	janitor:Destroy()
end)

janitor:Add(root, "unmount")
janitor:Add(container, "Destroy")

janitor:Add(pluginActiveConnection, "Disconnect")

janitor:Add(pluginDeactivationConnection, "Disconnect")
janitor:Add(pluginUnloadingConnection, "Disconnect")

root:render(app)

container.Parent = CoreGui
