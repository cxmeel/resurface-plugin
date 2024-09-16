local UserInputService = game:GetService("UserInputService")

local function calculateDpiScale(fallback: number?)
	local ok, scale = pcall(function()
		local buttonContentId =
			UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonA)
		local buttonScale = buttonContentId:lower():match("@([%d%.]-)x%.%w+$")

		return tonumber(buttonScale or fallback or 1)
	end)

	return ok and scale or fallback or 1
end

return calculateDpiScale
