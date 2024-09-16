local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local Preferences = require("@root/Stores/Preferences")

local useValue = require("@root/Lib/Store").useValue
local useBoolean = require("../Hooks/useBoolean")
local useDefaultProps = require("../Hooks/useDefaultProps")
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring
local useEffect = React.useEffect

local createNextOrder = require("../Lib/createNextOrder")
local withFont = require("../Lib/withFont")
local e = React.createElement

local function WigglyUnderlineButton(props: {
	text: string?,
	color: Color3?,
	disabled: boolean?,
	animate: boolean?,
	onClick: (rbx: ImageButton) -> ()?,
	native: { [string]: any }?,
	children: React.Node?,
})
	local theme = useTheme()

	local isHovered = useBoolean(false)
	local isReducedMotion = useValue(Preferences.isReducedMotion)

	local nextOrder = createNextOrder()

	local springs, api = useSpring(function()
		return {
			alpha = 0,
		}
	end)

	useEffect(
		function()
			if props.disabled or not isHovered.value or not props.text then
				return
			end

			if isReducedMotion or props.animate == false then
				return
			end

			api.start({
				from = {
					alpha = 0,
				},
				to = {
					alpha = 1,
				},
				config = {
					duration = 0.3,
					easing = ReactSpring.easings.linear,
				},
				loop = true,
			})

			return function()
				api.stop({ "alpha" })
			end
		end,
		{
			isHovered.value,
			props.disabled,
			props.text,
			isReducedMotion,
			props.animate,
		} :: { any }
	)

	local rootElementProps = useDefaultProps(
		{
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(
				theme.variables.textSize + theme.variables.spacing * 2,
				theme.variables.textSize + theme.variables.spacing * 2
			),
		},
		props.native,
		{
			[React.Event.Activated] = not props.disabled and props.onClick,
			[React.Event.MouseEnter] = not props.disabled and isHovered.enable,
			[React.Event.MouseLeave] = isHovered.disable,
		}
	)

	return e("ImageButton", rootElementProps, {
		layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, theme.variables.spacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		leftAttachment = props.children and e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
		}, props.children),

		container = props.text and e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
		}, {
			label = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				FontFace = withFont(theme.typography.body, Enum.FontWeight.ExtraBold),
				Text = props.text,
				TextColor3 = props.color or theme.colors.accent.default,
				TextSize = theme.variables.textSize,
			}),

			layout = e("UIListLayout", {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			underline = e("CanvasGroup", {
				GroupColor3 = props.color or theme.colors.accent.default,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				Size = UDim2.fromOffset(0, 4),
			}, {
				image = e("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://17425189240",
					ScaleType = Enum.ScaleType.Tile,
					Position = springs.alpha:map(function(alpha)
						return UDim2.fromOffset(-8 * alpha, 0)
					end),
					Size = UDim2.new(1, 8, 1, 0),
					TileSize = UDim2.fromOffset(8, 4),
					ClipsDescendants = true,
				}),
			}, {
				gradient = e("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.05, 0),
						NumberSequenceKeypoint.new(0.95, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}),
			}),
		}),
	})
end

return WigglyUnderlineButton
