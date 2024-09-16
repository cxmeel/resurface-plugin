local Array = require("@root/Lib/Array")
local React = require("@pkgs/React")

local SurfacePickerListItem = require("./SurfacePickerListItem")

local useBoolean = require("../Hooks/useBoolean")
local useTheme = require("../Hooks/useTheme")
local useEffect = React.useEffect

local createUniqueKey = require("../../Lib/createUniqueKey")
local e = React.createElement
local memo = React.memo

local function SurfacePickerListView(props: {
	surfaceTypes: { Enum.SurfaceType },
	highlightedSurfaceType: Enum.SurfaceType?,
	scrollingFrameRef: { current: ScrollingFrame? }?,
})
	local theme = useTheme()
	local uniqueKey = createUniqueKey()

	local doesOverflowY = useBoolean(
		props.scrollingFrameRef
				and props.scrollingFrameRef.current
				and props.scrollingFrameRef.current.AbsoluteCanvasSize.Y > props.scrollingFrameRef.current.AbsoluteSize.Y
			or false
	)

	useEffect(function()
		local scrollingFrame = props.scrollingFrameRef
			and props.scrollingFrameRef.current

		if not scrollingFrame then
			return
		end

		local connection = scrollingFrame
			:GetPropertyChangedSignal("AbsoluteCanvasSize")
			:Connect(function()
				local overlowsY = scrollingFrame.AbsoluteCanvasSize.Y
					> scrollingFrame.AbsoluteSize.Y
				doesOverflowY.set(overlowsY)
			end)

		return function()
			connection:Disconnect()
		end
	end, { props.scrollingFrameRef and props.scrollingFrameRef.current })

	local listItems = Array.map(props.surfaceTypes, function(surfaceType)
		local key = uniqueKey(surfaceType.Name)

		return e(SurfacePickerListItem, {
			surfaceType = surfaceType,
			highlighted = props.highlightedSurfaceType == surfaceType,
			key = key,
		})
	end)

	return e(React.Fragment, nil, {
		layout = e("UIListLayout", {
			Padding = UDim.new(0, theme.variables.spacing * 0.5),
			SortOrder = Enum.SortOrder.Name,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}),
		padding = e("UIPadding", {
			PaddingRight = doesOverflowY.value and UDim.new(
				0,
				theme.variables.spacing + theme.variables.scrollbarWidth
			) or nil,
			PaddingTop = UDim.new(0, theme.variables.spacing * 0.5),
		}),
	}, listItems)
end

return (memo(SurfacePickerListView) :: never) :: typeof(SurfacePickerListView)
