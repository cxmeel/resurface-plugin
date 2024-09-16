local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local useBoolean = require("../Hooks/useBoolean")
local useDefaultProps = require("../Hooks/useDefaultProps")
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring

local withInputEvents = require("../Lib/withInputEvents")
local e = React.createElement
local memo = React.memo

local ROOT_SIZE = Vector2.new(50, 28)
local HANDLE_SQUISH_OFFSET = 8

local function Switch(props: {
	selected: boolean?,
	disabled: boolean?,
	onClick: (rbx: TextButton) -> ()?,
	native: { [string]: any }?,
})
	local theme = useTheme()

	local isHovered = useBoolean(false)
	local isPressed = useBoolean(false)

	local handleSize = Vector2.one * ROOT_SIZE.Y
		- Vector2.new(theme.variables.borderWidth * 4, theme.variables.borderWidth * 4)

	local swatchId = props.disabled and "disabled"
		or isPressed.value and "pressed"
		or isHovered.value and "hovered"
		or "default"

	local backgroundColor = props.selected and theme.colors.accent
		or theme.colors.button
	local textColor = props.selected and theme.colors.onAccent or theme.colors.onButton

	local springs = useSpring({
		alpha = props.selected and 1 or 0,
		backgroundColor = (backgroundColor :: never)[swatchId],
		textColor = (textColor :: never)[swatchId],
		config = {
			duration = 0.125,
			easing = ReactSpring.easings.easeInCirc,
		},
	})

	local rootElementProps = useDefaultProps(
		{
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = springs.backgroundColor,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(ROOT_SIZE.X, ROOT_SIZE.Y),
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
		corners = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),

		background = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = springs.backgroundColor,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(
				1,
				-theme.variables.borderWidth * 2,
				1,
				-theme.variables.borderWidth * 2
			),
		}, {
			corners = e("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),

			handle = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = springs.textColor,
				BorderSizePixel = 0,
				Position = springs.alpha:map(function(alpha: number)
					return UDim2.new(
						0,
						handleSize.X / 2 + theme.variables.borderWidth,
						0.5,
						0
					)
						:Lerp(
							UDim2.new(
								1,
								-(handleSize.X / 2 + theme.variables.borderWidth),
								0.5,
								0
							),
							alpha
						)
				end),
				Size = springs.alpha:map(function(alpha)
					local alphaStart, alphaEnd = 0.2, 0.8
					local alphaDiff = alphaEnd - alphaStart

					local width = handleSize.X
					local height = handleSize.Y

					local squishHeight = height - HANDLE_SQUISH_OFFSET
					local squishWidth = width + HANDLE_SQUISH_OFFSET

					if alpha > alphaStart and alpha < alphaEnd then
						local t = (alpha - alphaStart) / alphaDiff

						height += (squishHeight - height) * (1 - math.abs(t - 0.5))
						width += (squishWidth - width) * (1 - math.abs(t - 0.5))
					end

					return UDim2.fromOffset(width, height)
				end),
			}, {
				corners = e("UICorner", {
					CornerRadius = UDim.new(1, 0) - UDim.new(0, 2),
				}),
			}),
		}),
	})
end

return (memo(Switch) :: never) :: typeof(Switch)
