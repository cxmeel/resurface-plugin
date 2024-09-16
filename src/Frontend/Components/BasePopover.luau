local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local Preferences = require("@root/Stores/Preferences")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring
local useEffect = React.useEffect
local useState = React.useState
local useRef = React.useRef

local createShortUuid = require("../Lib/createShortUuid")
local e = React.createElement

local DEFAULT_ANCHOR_POINT = Vector2.new(0.5, 1)
local DEFAULT_ANCHOR_OFFSET = Vector2.new(0, 4)
local DEFAULT_HORIZONTAL_ALIGNMENT = Enum.HorizontalAlignment.Center
local DEFAULT_VERTICAL_ALIGNMENT = Enum.VerticalAlignment.Top

local function readRef<T>(ref: T | { current: T }): T
	if typeof(ref) == "table" then
		return ref.current
	end

	return ref :: T
end

local function BasePopover(props: {
	visible: boolean?,
	anchorRef: GuiBase2d? | { current: GuiBase2d? }?,
	anchorPoint: Vector2?,
	anchorOffset: Vector2?,
	horizontalAlignment: Enum.HorizontalAlignment?,
	verticalAlignment: Enum.VerticalAlignment?,
	zindex: number?,
	interactable: boolean?,
	children: React.Node?,
})
	local isMounted, setIsMounted = useState(props.visible or false)
	local theme = useTheme()

	local popoverRef = useRef(createShortUuid())
	local anchor: GuiBase2d? = readRef(props.anchorRef)

	local isReducedMotion = useValue(Preferences.isReducedMotion)
	-- local useBounceAnimations = useValue(Preferences.useBounceAnimations)

	local springs, api = useSpring(function()
		return {
			visible = props.visible and 1 or 0,
		}
	end)

	useEffect(function()
		local alpha = props.visible and 1 or 0
		local easing: any = ReactSpring.easings.easeOutQuint

		if Preferences.useBounceAnimations() then
			easing = ReactSpring.easings.easeInOutBack
		end

		if alpha == 1 then
			setIsMounted(true)
		end

		api.start({
			visible = alpha,
			config = {
				easing = easing,
				duration = isReducedMotion and 0 or 0.225,
			},
		}):andThen(function()
			if alpha == 0 then
				setIsMounted(false)
			end
		end)

		return function()
			api.stop({ "visible" })
		end
	end, { props.visible })

	if not anchor or not isMounted or not props.children then
		return
	end

	local horizontalAlignment = props.horizontalAlignment
		or DEFAULT_HORIZONTAL_ALIGNMENT
	local verticalAlignment = props.verticalAlignment or DEFAULT_VERTICAL_ALIGNMENT
	local popoverAnchorPoint = Vector2.zero

	if horizontalAlignment == Enum.HorizontalAlignment.Center then
		popoverAnchorPoint = Vector2.new(0.5, 0)
	elseif horizontalAlignment == Enum.HorizontalAlignment.Right then
		popoverAnchorPoint = Vector2.xAxis
	end

	if verticalAlignment == Enum.VerticalAlignment.Center then
		popoverAnchorPoint = Vector2.new(popoverAnchorPoint.X, 0.5)
	elseif verticalAlignment == Enum.VerticalAlignment.Bottom then
		popoverAnchorPoint = Vector2.new(popoverAnchorPoint.X, 1)
	end

	local anchorPoint = props.anchorPoint or DEFAULT_ANCHOR_POINT
	local anchorOffset = props.anchorOffset or DEFAULT_ANCHOR_OFFSET

	local popoverPosition = anchor.AbsolutePosition
		+ anchorPoint * anchor.AbsoluteSize
		+ anchorOffset * Vector2.yAxis

	return e("ScreenGui", {
		key = `popover<{popoverRef.current}>`,
		DisplayOrder = props.zindex or theme.elevation.popover,
		Enabled = springs.visible:map(function(alpha)
			return alpha ~= 0
		end),
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		popover = e("CanvasGroup", {
			AnchorPoint = popoverAnchorPoint,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			GroupTransparency = springs.visible:map(function(alpha)
				return 1 - alpha
			end),
			Interactable = props.interactable,
			Position = UDim2.fromOffset(popoverPosition.X, popoverPosition.Y),
		}, {
			scale = e("UIScale", {
				Scale = springs.visible:map(function(alpha: number)
					if not Preferences.useBounceAnimations() then
						return 1
					end

					return alpha
				end),
			}),
		}, props.children) :: never,
	})
end

return BasePopover
