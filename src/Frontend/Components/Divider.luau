local React = require("@pkgs/React")

local useDefaultProps = require("../Hooks/useDefaultProps")
local useTheme = require("../Hooks/useTheme")

local e = React.createElement
local memo = React.memo

local function Divider(props: {
	orientation: ("horizontal" | "vertical")?,
	native: { [string]: any }?,
})
	local theme = useTheme()
	local size = UDim2.new(1, 0, 0, theme.variables.borderWidth)

	if props.orientation == "vertical" then
		size = UDim2.fromOffset(theme.variables.borderWidth, theme.variables.textSize)
	end

	local rootElementProps = useDefaultProps({
		BackgroundColor3 = theme.colors.onSurface,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Interactable = false,
		Size = size,
	}, props.native)

	return e("Frame", rootElementProps)
end

return (memo(Divider) :: never) :: typeof(Divider)
