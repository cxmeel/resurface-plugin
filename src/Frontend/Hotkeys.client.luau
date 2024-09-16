local UserInputService = game:GetService("UserInputService")

local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local keybindStrings = {
	CTRL = { Enum.KeyCode.LeftControl, Enum.KeyCode.RightControl },
	SHIFT = { Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift },
	ALT = { Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt },
}

local function keybindMatches(
	keybind: string | Enum.KeyCode,
	keycode: Enum.KeyCode
): boolean
	if typeof(keybind) == "EnumItem" then
		return keybind == keycode
	end

	for _, v in keybindStrings[keybind] do
		if v == keycode then
			return true
		end
	end

	return false
end

UserInputService.InputBegan:Connect(function(inputObject, robloxProcessed)
	if
		LocalStore.isListeningForKeybinds()
		or not LocalStore.isPluginActive()
		or robloxProcessed
	then
		return
	end

	local keycode = inputObject.KeyCode

	if keybindMatches(Preferences.keybindSurfacePickerWidget(), keycode) then
		LocalStore.currentWidget(function(current)
			return if current == "surfacePicker" then nil else "surfacePicker"
		end)
	elseif keybindMatches(Preferences.keybindApplyToAllFacesOverride(), keycode) then
		LocalStore.applyToAllfacesOverride(true)
	end

	if keycode == Enum.KeyCode.Escape then
		if LocalStore.currentWidget() then
			LocalStore.currentWidget(nil)
		else
			LocalStore.isPluginActive(false)
		end
	end
end)

UserInputService.InputEnded:Connect(function(inputObject)
	local keycode = inputObject.KeyCode

	if keybindMatches(Preferences.keybindApplyToAllFacesOverride(), keycode) then
		LocalStore.applyToAllfacesOverride(false)
	end
end)
