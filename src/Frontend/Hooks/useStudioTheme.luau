local Studio = settings():GetService("Studio")
local React = require("@pkgs/React")

local useEvent = require("./useEvent")
local useState = React.useState
local useMemo = React.useMemo

local function getStudioThemeId(theme: StudioTheme)
	local studioThemeId = theme.Name:lower()
	return studioThemeId
end

local function useStudioTheme()
	local theme, setTheme = useState(Studio.Theme)

	local themeId = useMemo(function()
		return getStudioThemeId(theme)
	end, { theme })

	useEvent(Studio.ThemeChanged, function()
		setTheme(Studio.Theme)
	end)

	return theme, themeId
end

return useStudioTheme
