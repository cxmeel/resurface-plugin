local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local IS_MACOS = GuiService.IsWindows == false

local function formatKeyCode(keycode: (string | Enum.KeyCode)?): string?
	if not keycode then
		return
	end

	if typeof(keycode) == "string" then
		return keycode:upper()
	end

	if keycode == Enum.KeyCode.Space then
		return keycode.Name:upper()
	elseif keycode == Enum.KeyCode.Backspace then
		return "BKSP"
	elseif keycode == Enum.KeyCode.Return then
		return "ENTER"
	elseif keycode == Enum.KeyCode.Escape then
		return "ESC"
	elseif
		keycode == Enum.KeyCode.LeftControl or keycode == Enum.KeyCode.RightControl
	then
		return IS_MACOS and "CMD" or "CTRL"
	elseif keycode == Enum.KeyCode.LeftShift or keycode == Enum.KeyCode.RightShift then
		return "SHIFT"
	elseif keycode == Enum.KeyCode.LeftAlt or keycode == Enum.KeyCode.RightAlt then
		return IS_MACOS and "OPT" or "ALT"
	end

	local keyString = UserInputService:GetStringForKeyCode(keycode)

	if keyString == "" then
		return keycode.Name:upper()
	end

	return keyString:upper()
end

return formatKeyCode
