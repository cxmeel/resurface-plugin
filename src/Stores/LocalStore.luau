local plugin: Plugin = plugin or script:FindFirstAncestorOfClass("Plugin")

local Store = require("@root/Lib/Store")

local Value = Store.Value
type Value<T> = Store.Value<T>

local validWidgetIds = {
	settings = true,
	surfacePicker = true,
}

local store = {
	isPluginActive = Value(false),
	currentWidget = Value(nil, {
		validate = function(value: string?)
			return not value or validWidgetIds[value]
		end,
	}) :: Value<nil | "settings" | "surfacePicker">,
	isListeningForKeybinds = Value(false),
	applyToAllfacesOverride = Value(false),
	isLegacyPluginTransition = Value(false),
	hasActionableSelection = Value(false),
}

store.isLegacyPluginTransition.changed:Connect(function(_, value)
	if not value then
		plugin:SetSetting("currentVersion", nil)
	end
end)

store.isPluginActive.changed:Connect(function(_, isActive)
	if isActive then
		return
	end

	store.currentWidget(nil)
end)

return store
