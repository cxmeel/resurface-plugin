local React = require("@pkgs/React")

local useDefaultProps = require("../Hooks/useDefaultProps")
local useTheme = require("../Hooks/useTheme")

local memo = React.memo
local e = React.createElement

local function ComponentGroup(props: {
	orientation: ("horizontal" | "vertical")?,
	spacing: UDim?,
	native: { [string]: any }?,
	onBoundsChanged: ((rbx: Frame) -> ())?,
	layoutNative: { [string]: any }?,
	children: React.Node?,
})
	local theme = useTheme()

	local rootElementProps = useDefaultProps(
		{
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		},
		props.native,
		{
			[React.Change.AbsoluteSize] = props.onBoundsChanged,
		}
	)

	local layoutProps = useDefaultProps({
		FillDirection = props.orientation == "vertical" and Enum.FillDirection.Vertical
			or Enum.FillDirection.Horizontal,
		Padding = props.spacing or UDim.new(0, theme.variables.spacing * 0.5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = props.orientation == "vertical"
				and Enum.VerticalAlignment.Top
			or Enum.VerticalAlignment.Center,
	}, props.layoutNative)

	return e("Frame", rootElementProps, {
		layout = e("UIListLayout", layoutProps),
	}, props.children)
end

return (memo(ComponentGroup) :: never) :: typeof(ComponentGroup)
