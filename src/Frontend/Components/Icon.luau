local React = require("@pkgs/React")

local useDefaultProps = require("../Hooks/useDefaultProps")
local useDpiScale = require("../Hooks/useDpiScale")
local useTheme = require("../Hooks/useTheme")
local useMemo = React.useMemo

local e = React.createElement
local memo = React.memo

export type TarmacImage = {
	Image: string,
	ImageRectSize: Vector2?,
	ImageRectOffset: Vector2?,
}

export type IconContent = string | (dpiScale: number) -> string | TarmacImage

local function Icon(props: {
	icon: IconContent,
	color: (Color3 | unknown)?,
	dpiScale: number?,
	native: { [string]: any }?,
})
	local dpiScale = useDpiScale()
	local theme = useTheme()

	local nativeIconProps = useMemo(function()
		local iconProps = typeof(props.icon) == "function"
				and props.icon(props.dpiScale or dpiScale)
			or props.icon

		if typeof(iconProps) == "string" then
			return { Image = iconProps } :: TarmacImage
		end

		return iconProps :: TarmacImage
	end, { props.icon, props.dpiScale } :: { any })

	local rootElementProps = useDefaultProps({
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(theme.variables.textSize, theme.variables.textSize),
		ImageColor3 = props.color,
	}, props.native, nativeIconProps)

	return e("ImageLabel", rootElementProps)
end

return (memo(Icon) :: never) :: typeof(Icon)
