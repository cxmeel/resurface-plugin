local plugin: Plugin = plugin or script:FindFirstAncestorOfClass("Plugin")
local HttpService = game:GetService("HttpService")
local Studio = settings():GetService("Studio")

local IconMap = require("@root/Assets/IconMap")
local Preferences = require("@root/Stores/Preferences")

local Icon = require("./Components/Icon")

local calculateDpiScale = require("./Lib/calculateDpiScale")
local createUniqueKey = require("../Lib/createUniqueKey")
local formatEnumName = require("./Lib/formatEnumName")

local SURFACE_TYPES: { Enum.SurfaceType } = Enum.SurfaceType:GetEnumItems()

table.sort(SURFACE_TYPES, function(a, b)
	return a.Name < b.Name
end)

local SURFACE_ICONS = {
	[Enum.SurfaceType.Glue] = IconMap.Misc.surface_weld_icon,
	[Enum.SurfaceType.Hinge] = IconMap.Misc.surface_hinge_icon,
	[Enum.SurfaceType.Inlet] = IconMap.Misc.surface_inlet_icon,
	[Enum.SurfaceType.Motor] = IconMap.Misc.surface_motor_icon,
	[Enum.SurfaceType.Smooth] = IconMap.Misc.surface_smooth_icon,
	[Enum.SurfaceType.SmoothNoOutlines] = IconMap.Misc.surface_smooth_icon,
	[Enum.SurfaceType.SteppingMotor] = IconMap.Misc.surface_motor_icon,
	[Enum.SurfaceType.Studs] = IconMap.Misc.surface_studs_icon,
	[Enum.SurfaceType.Universal] = IconMap.Misc.surface_universal_icon,
	[Enum.SurfaceType.Weld] = IconMap.Misc.surface_weld_icon,
}

local additionalActions: {
	{
		name: string,
		action: (() -> ())?,
		icon: Icon.IconContent?,
	}
} =
	{
		{
			name = "Show Widget",
			-- action = function() end,
			icon = function(...)
				if Studio.Theme.Name == "Light" then
					return IconMap.Misc.open_new_black(...)
				end

				return IconMap.Misc.open_new_white(...)
			end,
		},
	}

local function showClassicMenu(callback: ((action: PluginAction?) -> ())?)
	local menuId = HttpService:GenerateGUID(false):sub(1, 7):lower()

	local baseMenu = plugin:CreatePluginMenu(menuId)
	local actions = {}

	local uniqueKey = createUniqueKey()
	local dpiScale = calculateDpiScale()

	for _, surfaceType in SURFACE_TYPES do
		local icon = SURFACE_ICONS[surfaceType](dpiScale)
		local key = `{menuId}_{uniqueKey(surfaceType.Name)}`

		local action = baseMenu:AddNewAction(key, formatEnumName(surfaceType), icon)

		action.Triggered:Connect(function()
			Preferences.selectedSurface(surfaceType)
		end)

		actions[key] = action
	end

	baseMenu:AddSeparator()

	for _, item in additionalActions do
		local key = `{menuId}_{uniqueKey(item.name)}`
		local icon: Icon.TarmacImage? = item.icon :: never

		if typeof(icon) == "function" then
			icon = icon(dpiScale)
		end

		if typeof(icon) == "string" then
			icon = { Image = icon } :: Icon.TarmacImage
		end

		local action = baseMenu:AddNewAction(key, item.name, icon and icon.Image)

		if item.action then
			action.Triggered:Connect(function()
				item.action()
			end)
		end

		actions[key] = action
	end

	local thread = task.spawn(function()
		local selectedAction = baseMenu:ShowAsync()

		if callback then
			callback(selectedAction)
		end
	end)

	return function()
		task.cancel(thread)
		baseMenu:Destroy()

		for _, action in actions do
			action:Destroy()
		end
	end
end

return {
	show = showClassicMenu,
}
