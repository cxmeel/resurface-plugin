local GuiService = game:GetService("GuiService")

local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local BasePopover = require("./BasePopover")

local useValue = require("@root/Lib/Store").useValue
local useDefaultProps = require("../Hooks/useDefaultProps")
local useImperativeHandle = React.useImperativeHandle
local useBoolean = require("../Hooks/useBoolean")
local useDpiScale = require("../Hooks/useDpiScale")
local useTheme = require("../Hooks/useTheme")
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef

local createNextOrder = require("../Lib/createNextOrder")
local formatKeyCode = require("../Lib/formatKeyCode")
local withFont = require("../Lib/withFont")
local e = React.createElement
local memo = React.memo

local isMacOS = GuiService.IsWindows == false

local function Tooltip(
	props: {
		title: string?,
		text: string?,
		keycode: (Enum.KeyCode | string)?, -- | "CTRL" | "CMD" | "SHIFT" | "ALT" | "OPTION")?,
		visible: boolean?,
		disabled: boolean?,
		rootRef: { current: GuiBase2d? }?,
		native: { [string]: any }?,
		children: React.Node?,
	}
)
	local isHovered = useBoolean(false)
	local rootElementRef = useRef(nil :: Frame?)

	useImperativeHandle(props.rootRef, function()
		return rootElementRef.current
	end)

	local theme = useTheme()
	local dpiScale = useDpiScale()

	local pluginActive = useValue(LocalStore.isPluginActive)
	local transparencyScale = useValue(Preferences.transparencyScale)

	local nextOrder = createNextOrder()

	local rootElementProps = useDefaultProps(
		{
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		},
		props.native,
		{
			ref = rootElementRef,
			[React.Event.MouseEnter] = not props.disabled and isHovered.enable,
			[React.Event.MouseLeave] = isHovered.disable,
		}
	)

	useEffect(function()
		if not pluginActive then
			isHovered.disable()
		end
	end, { pluginActive })

	if not props.title and not props.text and not props.keycode then
		return props.children
	end

	local keycode = useMemo(function()
		local keycodeTitle = formatKeyCode(props.keycode)

		if props.keycode == "SHIFT" then
			keycodeTitle = "⇧ SHIFT"
		elseif props.keycode == "CTRL" or props.keycode == "CMD" then
			keycodeTitle = isMacOS and "⌘ CMD" or "CTRL"
		elseif props.keycode == "ALT" or props.keycode == "OPTION" then
			keycodeTitle = isMacOS and "⌥ OPT" or "ALT"
		end

		return keycodeTitle
	end, { props.keycode })

	return e("Frame", rootElementProps, {
		popover = not props.disabled and e(BasePopover, {
			visible = isHovered.value,
			anchorRef = rootElementRef :: any,
			zindex = theme.elevation.tooltip,
			interactable = false,
		}, {
			layout = e("UIListLayout", {
				Padding = UDim.new(),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
		}, {
			tail = e("ImageLabel", {
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				Size = UDim2.fromOffset(16, 8),
				Image = IconMap.Misc.arrow_up(dpiScale),
				ImageColor3 = theme.colors.surface,
				ImageTransparency = theme.variables.surfaceTransparency,
			}),

			container = e("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = theme.colors.surface,
				BackgroundTransparency = theme.variables.surfaceTransparency
					* transparencyScale,
				BorderSizePixel = 0,
				LayoutOrder = nextOrder(),
			}, {
				corners = e("UICorner", {
					CornerRadius = theme.variables.cornerRadius
						+ UDim.new(0, theme.variables.spacing),
				}),
				padding = e("UIPadding", {
					PaddingTop = UDim.new(0, theme.variables.spacing),
					PaddingBottom = UDim.new(0, theme.variables.spacing),
					PaddingLeft = UDim.new(0, theme.variables.spacing),
					PaddingRight = UDim.new(0, theme.variables.spacing),
				}),
				layout = e("UIListLayout", {
					Padding = UDim.new(0, theme.variables.spacing * 0.5),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				maxSize = e("UISizeConstraint", {
					MaxSize = theme.variables.tooltipMaxSize,
				}),
			}, {
				header = (props.title or props.keycode) and e("Frame", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					LayoutOrder = nextOrder(),
					Size = UDim2.fromScale(1, 0),
				}, {
					layout = e("UIListLayout", {
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Wraps = true,
					}),
				}, {
					title = props.title and e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = nextOrder(),
						FontFace = withFont(
							theme.typography.title,
							Enum.FontWeight.ExtraBold
						),
						TextColor3 = theme.colors.onSurface,
						TextSize = theme.variables.textSize,
						Text = props.title,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),

					keybind = props.keycode
						and e("TextLabel", {
							AutomaticSize = Enum.AutomaticSize.XY,
							BackgroundColor3 = theme.colors.accent.default,
							LayoutOrder = nextOrder(),
							FontFace = withFont(
								theme.typography.mono,
								Enum.FontWeight.ExtraBold
							),
							TextColor3 = theme.colors.onAccent.default,
							TextSize = theme.variables.textSize,
							Text = keycode,
							TextWrapped = true,
							TextXAlignment = Enum.TextXAlignment.Left,
						}, {
							corners = e("UICorner", {
								CornerRadius = theme.variables.cornerRadius,
							}),
							padding = e("UIPadding", {
								PaddingLeft = UDim.new(
									0,
									theme.variables.spacing * 0.5
								),
								PaddingRight = UDim.new(
									0,
									theme.variables.spacing * 0.5
								),
								PaddingTop = UDim.new(0, theme.variables.spacing * 0.5),
								PaddingBottom = UDim.new(
									0,
									theme.variables.spacing * 0.5
								),
							}),
						}),
				}),

				text = props.text and e("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					LayoutOrder = nextOrder(),
					FontFace = theme.typography.body,
					TextColor3 = theme.colors.onSurface,
					TextSize = theme.variables.textSize,
					Text = props.text,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		}),
	}, props.children)
end

return (memo(Tooltip) :: never) :: typeof(Tooltip)
