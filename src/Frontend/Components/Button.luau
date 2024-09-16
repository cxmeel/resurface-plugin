local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local Preferences = require("@root/Stores/Preferences")

local Icon = require("./Icon")

local useValue = require("@root/Lib/Store").useValue
local useBoolean = require("../Hooks/useBoolean")
local useDefaultProps = require("../Hooks/useDefaultProps")
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring

local createNextOrder = require("../Lib/createNextOrder")
local withFont = require("../Lib/withFont")
local withInputEvents = require("../Lib/withInputEvents")
local e = React.createElement

local function Button(props: {
	text: string?,
	textOrder: number?,
	icon: Icon.IconContent?,
	disabled: boolean?,
	selected: boolean?,
	fullWidth: boolean?,
	rounded: boolean?,
	onClick: (rbx: TextButton) -> ()?,
	native: { [string]: any }?,
	children: React.Node?,
})
	local theme = useTheme()

	local isReducedMotion = useValue(Preferences.isReducedMotion)

	local isPressed = useBoolean(false)
	local isHovered = useBoolean(false)

	local nextOrder = createNextOrder(props.textOrder)

	local swatchId = props.disabled and "disabled"
		or isPressed.value and "pressed"
		or isHovered.value and "hovered"
		or "default"

	local backgroundColor = props.selected and theme.colors.accent
		or theme.colors.button
	local textColor = props.selected and theme.colors.onAccent or theme.colors.onButton
	local fontFace = withFont(theme.typography.body, Enum.FontWeight.SemiBold)

	local springs = useSpring({
		borderColor = theme.colors.buttonBorder[swatchId],
		backgroundColor = (backgroundColor :: never)[swatchId],
		textColor = (textColor :: never)[swatchId],
		config = {
			duration = isReducedMotion and 0 or 0.125,
			easing = ReactSpring.easings.easeOutQuad,
		},
	})

	local rootElementProps = useDefaultProps(
		{
			AutoButtonColor = false,
			AutomaticSize = props.fullWidth and Enum.AutomaticSize.Y
				or Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = props.fullWidth and UDim2.fromScale(1, 0),
		},
		props.native,
		{
			Active = not props.disabled,
			Interactable = not props.disabled,
			Text = "",

			[React.Event.InputBegan] = withInputEvents({
				hovered = isHovered.enable,
				pressed = isPressed.enable,
			}),
			[React.Event.InputEnded] = withInputEvents({
				hovered = isHovered.disable,
				pressed = isPressed.disable,
			}),
			[React.Event.Activated] = function(rbx: any)
				if not props.disabled and props.onClick then
					props.onClick(rbx)
				end
			end,
		}
	)

	return e("TextButton", rootElementProps, {
		padding = e("UIPadding", {
			PaddingTop = UDim.new(0, theme.variables.borderWidth),
			PaddingBottom = UDim.new(0, theme.variables.borderWidth),
			PaddingLeft = UDim.new(0, theme.variables.borderWidth),
			PaddingRight = UDim.new(0, theme.variables.borderWidth),
		}),
		corners = e("UICorner", {
			CornerRadius = props.rounded and UDim.new(1, 0)
				or theme.variables.cornerRadius,
		}),

		container = e("Frame", {
			AutomaticSize = props.fullWidth and Enum.AutomaticSize.Y
				or Enum.AutomaticSize.XY,
			BackgroundColor3 = springs.backgroundColor,
			BorderSizePixel = 0,
			Size = props.fullWidth and UDim2.new(
				1,
				0,
				0,
				theme.variables.textSize + theme.variables.spacing * 2
			) or UDim2.fromOffset(
				theme.variables.textSize + theme.variables.spacing * 2,
				theme.variables.textSize + theme.variables.spacing * 2
			),
		}, {
			corners = e("UICorner", {
				CornerRadius = props.rounded and UDim.new(1, 0)
					or theme.variables.cornerRadius
						- UDim.new(0, theme.variables.borderWidth),
			}),
			layout = e("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			padding = e("UIPadding", {
				PaddingTop = UDim.new(0, theme.variables.spacing),
				PaddingBottom = UDim.new(0, theme.variables.spacing),
				PaddingLeft = UDim.new(0, theme.variables.spacing),
				PaddingRight = UDim.new(0, theme.variables.spacing),
			}),
		}, {
			stroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = springs.borderColor,
				Thickness = theme.variables.borderWidth,
			}),
		}, {
			icon = props.icon and e(Icon, {
				icon = props.icon,
				color = springs.textColor,
				native = {
					LayoutOrder = nextOrder(),
				},
			}),

			text = props.text and e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = fontFace,
				Text = props.text,
				TextColor3 = springs.textColor,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
			}),
		}, props.children),
	})
end

return Button
