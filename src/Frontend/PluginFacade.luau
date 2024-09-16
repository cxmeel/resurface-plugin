local RuntimeScript = script.Parent.Parent

local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Manifest = require("@root/Manifest")

local StudioPluginToolbar = require("./Components/StudioPlugin/StudioPluginToolbar")
local StudioPluginToolbarButton =
	require("./Components/StudioPlugin/StudioPluginToolbarButton")

local useValue = require("@root/Lib/Store").useValue
local useDpiScale = require("./Hooks/useDpiScale")
local useStudioTheme = require("./Hooks/useStudioTheme")
local useMemo = React.useMemo

local e = React.createElement
local memo = React.memo

local buildSessionId = RuntimeScript:GetAttribute("BuildSessionId")
local buildDate = RuntimeScript:GetAttribute("BuildDate")
local buildTime = RuntimeScript:GetAttribute("BuildTime")

local function PluginFacade()
	local pluginActive = useValue(LocalStore.isPluginActive)
	local isLegacyPluginTransition = useValue(LocalStore.isLegacyPluginTransition)

	local _, studioThemeId = useStudioTheme()
	local dpiScale = useDpiScale()

	local pluginIcon = useMemo(function()
		if buildSessionId then
			if studioThemeId == "light" then
				return IconMap.ProductIcons.light_mode_dev_icon(dpiScale)
			end

			return IconMap.ProductIcons.dark_mode_dev_icon(dpiScale)
		end

		if isLegacyPluginTransition then
			if studioThemeId == "light" then
				return IconMap.ProductIcons.classic_light_mode_icon(dpiScale)
			end

			return IconMap.ProductIcons.classic_dark_mode_icon(dpiScale)
		end

		if studioThemeId == "light" then
			return IconMap.ProductIcons.light_mode_icon(dpiScale)
		end

		return IconMap.ProductIcons.dark_mode_icon(dpiScale)
	end, { dpiScale, studioThemeId, isLegacyPluginTransition } :: { any })

	local widgetToggleButtonText = Manifest.product.display_name
	local widgetToggleButtonTooltip = Manifest.product.description

	if buildSessionId then
		widgetToggleButtonText ..= ` (#{buildSessionId:sub(1, 7):lower()})`
		widgetToggleButtonTooltip ..= `\n▶ {buildDate} @ {buildTime}`
	end

	return e(StudioPluginToolbar.Provider, {
		name = "Resurface",
	}, {
		widgetToggle = e(StudioPluginToolbarButton, {
			id = "resurface.mainWidgetToggle",
			tooltip = widgetToggleButtonTooltip,
			icon = pluginIcon,
			text = widgetToggleButtonText,
			active = pluginActive,
			onClick = function()
				LocalStore.isPluginActive(function(current)
					return not current
				end)
			end,
		}),
	})
end

return (memo(PluginFacade) :: never) :: typeof(PluginFacade)
