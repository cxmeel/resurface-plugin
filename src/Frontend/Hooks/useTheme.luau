-- local Studio = settings():GetService("Studio")

-- local React = require("@pkgs/React")

local DarkTheme = require("../Themes/Dark")

local function useTheme()
	-- local isLight, setIsLight = React.useState(Studio.Theme.Name == "Light")

	-- React.useEffect(function()
	-- 	local connection = Studio.ThemeChanged:Connect(function()
	-- 		local isLightTheme = Studio.Theme.Name == "Light"
	-- 		setIsLight(isLightTheme)
	-- 	end)

	-- 	return function()
	-- 		connection:Disconnect()
	-- 	end
	-- end, {})

	-- local matchedTheme = isLight and LightTheme or DarkTheme
	-- local resolvedTheme = matchedTheme

	-- return resolvedTheme, isLight
	return DarkTheme, false
end

return useTheme
