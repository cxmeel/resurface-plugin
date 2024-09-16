local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local IconMap = require("@root/Assets/IconMap")

local Icon = require("./Icon")

local useDefaultProps = require("../Hooks/useDefaultProps")
local useImperativeHandle = React.useImperativeHandle
local useBoolean = require("../Hooks/useBoolean")
local useTheme = require("../Hooks/useTheme")
local useLayoutEffect = React.useLayoutEffect
local useSpring = ReactSpring.useSpring
local useRef = React.useRef

local withFont = require("../Lib/withFont")
local e = React.createElement

local function TextBox(props: {
	disabled: boolean?,
	selected: boolean?,
	readonly: boolean?,
	fullWidth: boolean?,
	autofocus: boolean?,
	text: string?,
	placeholder: string?,
	errorText: string?,
	autocompletes: { string }?,
	icon: Icon.IconContent?,
	textBoxRef: { current: TextBox? }?,
	onChange: (rbx: TextBox, text: string) -> ()?,
	onFocus: (rbx: TextBox) -> ()?,
	onFocusLost: (rbx: TextBox, text: string, enterPressed: boolean) -> ()?,
	native: { [string]: any }?,
	textboxNative: { [string]: any }?,
})
	local textBoxRef = useRef(nil :: TextBox?)
	local theme = useTheme()

	local isHovered = useBoolean(false)
	local isFocused = useBoolean(false)
	local hasText = useBoolean(props.text and props.text ~= "")

	local swatchId = props.disabled and "disabled"
		or isFocused.value and "focused"
		or isHovered.value and "hovered"
		or "default"

	local borderColor = theme.colors.textboxBorder
	local backgroundColor = theme.colors.textbox
	local textColor = theme.colors.onTextbox
	local fontFace = withFont(theme.typography.body, Enum.FontWeight.Medium)

	useImperativeHandle(props.textBoxRef, function()
		return textBoxRef.current
	end, { textBoxRef.current })

	local springs = useSpring({
		borderColor = (borderColor :: never)[swatchId],
		backgroundColor = (backgroundColor :: never)[swatchId],
		textColor = (textColor :: never)[swatchId],
		iconColor = isFocused.value and (borderColor :: never)[swatchId]
			or hasText.value and (textColor :: never)[swatchId]
			or textColor.disabled,
		config = {
			duration = 0.125,
			easing = ReactSpring.easings.easeOutQuad,
		},
	})

	local rootElementProps = useDefaultProps(
		{
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Size = props.fullWidth and UDim2.fromScale(1, 0),
		},
		props.native,
		{
			Text = "",
			[React.Event.MouseEnter] = isHovered.enable,
			[React.Event.MouseLeave] = isHovered.disable,
			[React.Event.Activated] = function()
				if not props.disabled and textBoxRef.current then
					textBoxRef.current:CaptureFocus()
				end
			end,
		}
	)

	local textboxProps = useDefaultProps(
		{
			AutomaticSize = props.fullWidth and Enum.AutomaticSize.Y
				or Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			FontFace = fontFace,
			ClipsDescendants = true,
			LayoutOrder = 2,
			PlaceholderColor3 = theme.colors.onTextbox.disabled,
			PlaceholderText = props.placeholder,
			Size = props.fullWidth and UDim2.fromScale(1, 0),
			Text = "",
			TextColor3 = springs.textColor,
			TextSize = theme.variables.textSize,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		},
		props.textboxNative,
		{
			ref = textBoxRef,
			[React.Event.FocusLost] = function(rbx, enterPressed)
				isFocused.disable()

				if props.onFocusLost then
					props.onFocusLost(rbx, rbx.Text, enterPressed)
				end
			end,
			[React.Event.Focused] = function(rbx)
				isFocused.enable()

				if props.onFocus then
					props.onFocus(rbx)
				end
			end,
			[React.Change.Text] = function(rbx)
				if rbx.Text == "" then
					hasText.disable()
				else
					hasText.enable()
				end

				if props.onChange then
					props.onChange(rbx, rbx.Text)
				end
			end,
		}
	)

	useLayoutEffect(function()
		local rbx = textBoxRef.current

		if props.text and rbx then
			rbx.Text = props.text
		end

		if props.autofocus and rbx then
			rbx:CaptureFocus()

			rbx.CursorPosition = props.text and #props.text + 1 or -1
			rbx.SelectionStart = props.text and 1 or -1
		end
	end, {})

	return e("TextButton", rootElementProps, {
		padding = e("UIPadding", {
			PaddingBottom = UDim.new(0, theme.variables.borderWidth),
			PaddingLeft = UDim.new(0, theme.variables.borderWidth),
			PaddingRight = UDim.new(0, theme.variables.borderWidth),
			PaddingTop = UDim.new(0, theme.variables.borderWidth),
		}),
	}, {
		container = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = springs.backgroundColor,
			BorderSizePixel = 0,
			Size = props.fullWidth and UDim2.fromScale(1, 0),
		}, {
			corners = e("UICorner", {
				CornerRadius = theme.variables.cornerRadius,
			}),
			stroke = e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = springs.borderColor,
				Thickness = theme.variables.borderWidth,
			}),
			layout = e("UIListLayout", {
				Padding = UDim.new(),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}, {
			prefixIcon = props.icon and e("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(
					theme.variables.textSize,
					theme.variables.textSize
				),
				LayoutOrder = 1,
			}, {
				aspectRatio = e("UIAspectRatioConstraint", {
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),

				icon = e(Icon, {
					icon = props.icon,
					color = springs.iconColor,
					native = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
					},
				}),
			}),

			textbox = e("TextBox", textboxProps, {
				padding = e("UIPadding", {
					PaddingTop = UDim.new(0, theme.variables.spacing),
					PaddingRight = UDim.new(0, theme.variables.spacing),
					PaddingBottom = UDim.new(0, theme.variables.spacing),
					PaddingLeft = props.icon and UDim.new()
						or UDim.new(0, theme.variables.spacing),
				}),
			}),

			clearButton = hasText.value and e("TextButton", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(
					theme.variables.textSize,
					theme.variables.textSize
				),
				LayoutOrder = 3,
				Text = "",

				[React.Event.Activated] = function()
					if textBoxRef.current then
						textBoxRef.current.Text = ""
						textBoxRef.current:CaptureFocus()
					end
				end,
			}, {
				aspectRatio = e("UIAspectRatioConstraint", {
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}),

				icon = e(Icon, {
					icon = IconMap.Icons.backspace,
					color = springs.onTextbox,
					native = {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
					},
				}),
			}),
		}),
	})
end

return TextBox
