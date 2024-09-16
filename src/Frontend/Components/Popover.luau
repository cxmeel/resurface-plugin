local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local BasePopover = require("./BasePopover")

local useValue = require("@root/Lib/Store").useValue
local useDpiScale = require("../Hooks/useDpiScale")
local useTheme = require("../Hooks/useTheme")
local useMemo = React.useMemo

local createNextOrder = require("../Lib/createNextOrder")
local e = React.createElement
local memo = React.memo

local POPOVER_TAIL_SIZE = Vector2.new(16, 8)

local function Popover(props: {
	anchorRef: { current: GuiBase2d? },
	visible: boolean?,
	showTail: boolean?,
	padding: number?,
	containerNative: { [string]: any }?,
	scrollingFrameRef: { current: ScrollingFrame? },
	stickyHeader: React.Node?,
	children: React.Node?,
})
	local theme = useTheme()
	local dpiScale = useDpiScale()

	local nextOrder = createNextOrder()
	local showTail = props.showTail ~= false

	local pluginActive = useValue(LocalStore.isPluginActive)
	local transparencyScale = useValue(Preferences.transparencyScale)

	local popoverHeight = useMemo(
		function()
			local height = theme.variables.popoverMaxSize.Y
			local anchorRef = props.anchorRef.current

			if anchorRef then
				local anchorBottom = anchorRef.AbsolutePosition.Y
					+ anchorRef.AbsoluteSize.Y
				local viewportHeight = workspace.CurrentCamera.ViewportSize.Y
				local tailHeight = showTail and POPOVER_TAIL_SIZE.Y or 0

				if height + anchorBottom + tailHeight > viewportHeight then
					height = viewportHeight - anchorBottom - tailHeight
				end
			end

			return height
		end,
		{
			theme.variables.popoverMaxSize,
			props.visible,
			props.showTail,
		} :: { any }
	)

	return e(BasePopover, {
		visible = if pluginActive then props.visible else false,
		anchorRef = props.anchorRef,
	}, {
		tail = showTail and e("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromOffset(POPOVER_TAIL_SIZE.X, POPOVER_TAIL_SIZE.Y),
			Image = IconMap.Misc.arrow_up(dpiScale),
			ImageColor3 = theme.colors.surface,
			ImageTransparency = theme.variables.surfaceTransparency * transparencyScale,
		}),

		container = e("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = theme.colors.surface,
			BackgroundTransparency = theme.variables.surfaceTransparency
				* transparencyScale,
			Size = UDim2.fromOffset(theme.variables.popoverMaxSize.X, popoverHeight),
			Position = showTail and UDim2.fromOffset(0, POPOVER_TAIL_SIZE.Y),
			LayoutOrder = nextOrder(),
			Text = "",
		}, {
			corners = e("UICorner", {
				CornerRadius = theme.variables.cornerRadius
					+ UDim.new(0, props.padding or theme.variables.spacing),
			}),
			padding = e("UIPadding", {
				PaddingTop = UDim.new(0, props.padding or theme.variables.spacing),
				PaddingBottom = UDim.new(0, props.padding or theme.variables.spacing),
				PaddingLeft = UDim.new(0, props.padding or theme.variables.spacing),
				PaddingRight = UDim.new(0, props.padding or theme.variables.spacing),
			}),
		}, {
			layout = props.stickyHeader and e("UIListLayout", {
				Padding = UDim.new(0, theme.variables.spacing),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalFlex = Enum.UIFlexAlignment.Fill,
			}),
		}, {
			stickyHeader = props.stickyHeader and e("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				Size = UDim2.fromScale(1, 0),
			}, props.stickyHeader),
		}, {
			container = e("ScrollingFrame", {
				ref = props.scrollingFrameRef,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = nextOrder(),
				Size = UDim2.fromScale(1, 1),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.fromScale(1, 0),
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarImageColor3 = theme.colors.onSurface,
				ScrollBarThickness = theme.variables.scrollbarWidth,
				ScrollBarImageTransparency = theme.variables.scrollbarTransparency
					* transparencyScale,
				BottomImage = IconMap.Misc.scrollbar_bottom(dpiScale),
				MidImage = IconMap.Misc.scrollbar_middle(dpiScale),
				TopImage = IconMap.Misc.scrollbar_top(dpiScale),
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			}, props.children),
		}),
	})
end

return (memo(Popover) :: never) :: typeof(Popover)
