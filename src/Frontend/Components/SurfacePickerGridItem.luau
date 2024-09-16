local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local SurfacePreview = require("./SurfacePreview/SurfacePreview")

local useValue = require("@root/Lib/Store").useValue
local useImperativeHandle = React.useImperativeHandle
local useBoolean = require("../Hooks/useBoolean")
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring
local useRef = React.useRef

local formatEnumName = require("../Lib/formatEnumName")
local withFont = require("../Lib/withFont")
local e = React.createElement
local memo = React.memo

local NUM_GRID_COLUMNS = 3

local function GridItemSurfacePreview(props: {
	backgroundColor: Color3?,
	surfaceType: Enum.SurfaceType,
	visible: boolean?,
	previewRef: { current: SurfacePreview.RefApi? }?,
})
	local springs, api = useSpring(function()
		return {
			cursorOffset = Vector2.zero,
		}
	end)

	useImperativeHandle(props.previewRef, function()
		return {
			updateCursorOffset = function(offset: Vector2)
				api.start({
					cursorOffset = offset,
					config = {
						easing = ReactSpring.easings.easeOutQuint,
						duration = 0.1,
					},
				})
			end,
			revertCursorOffset = function()
				api.start({
					cursorOffset = Vector2.zero,
					config = {
						easing = ReactSpring.easings.easeOutBack,
						duration = 0.2,
					},
				})
			end,
		}
	end, {})

	if props.visible == false then
		return
	end

	return e(SurfacePreview, {
		surfaceType = props.surfaceType,
		partCframe = springs.cursorOffset:map(function(alpha: Vector2)
			return CFrame.fromOrientation(
				math.rad(45 * -alpha.Y),
				math.pi,
				math.rad(45 * alpha.X)
			)
		end),
		native = {
			BackgroundColor3 = props.backgroundColor,
			Size = UDim2.fromScale(1, 1),
		},
	})
end

local function SurfacePickerGridItem(props: {
	surfaceType: Enum.SurfaceType,
	highlighted: boolean?,
})
	local theme = useTheme()

	local isHovered = useBoolean(false)
	local isSelected = useValue(Preferences.selectedSurface) == props.surfaceType

	local previewRef = useRef(nil :: SurfacePreview.RefApi?)

	local isHighlighted = (isSelected or (props.highlighted or isHovered.value))

	return e("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1 / NUM_GRID_COLUMNS, -NUM_GRID_COLUMNS, 0, 0),
		ClipsDescendants = true,
		Text = "",

		[React.Event.MouseEnter] = isHovered.enable,
		[React.Event.MouseLeave] = function()
			isHovered.disable()

			if previewRef.current then
				previewRef.current.revertCursorOffset()
			end
		end,

		[React.Event.Activated] = function()
			Preferences.selectedSurface(props.surfaceType)
			LocalStore.currentWidget(nil)
		end,

		[React.Event.InputChanged] = function(rbx: TextButton, input: InputObject)
			if
				not previewRef.current
				or input.UserInputType ~= Enum.UserInputType.MouseMovement
			then
				return
			end

			local cursorX = input.Position.X
			local cursorY = input.Position.Y

			local rbxHalfSize = rbx.AbsoluteSize / 2
			local rbxCentre = rbx.AbsolutePosition + rbxHalfSize

			local cursorOffsetX = cursorX - rbxCentre.X
			local cursorOffsetY = cursorY - rbxCentre.Y

			local cursorOffsetAlphaX = math.clamp(cursorOffsetX / rbxHalfSize.X, -1, 1)
			local cursorOffsetAlphaY = math.clamp(cursorOffsetY / rbxHalfSize.Y, -1, 1)

			previewRef.current.updateCursorOffset(
				Vector2.new(cursorOffsetAlphaX, cursorOffsetAlphaY)
			)
		end :: never,
	}, {
		aspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Width,
		}),
		padding = e("UIPadding", {
			PaddingBottom = UDim.new(0, theme.variables.borderWidth),
			PaddingLeft = UDim.new(0, theme.variables.borderWidth),
			PaddingRight = UDim.new(0, theme.variables.borderWidth),
			PaddingTop = UDim.new(0, theme.variables.borderWidth),
		}),
	}, {
		container = e("Frame", {
			BackgroundTransparency = isSelected and 0 or 1,
			BackgroundColor3 = isSelected and theme.colors.accent.default or nil,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
		}, {
			corners = e("UICorner", {
				CornerRadius = theme.variables.cornerRadius,
			}),
			padding = e("UIPadding", {
				PaddingBottom = UDim.new(0, theme.variables.spacing / 2),
				PaddingLeft = UDim.new(0, theme.variables.spacing / 2),
				PaddingRight = UDim.new(0, theme.variables.spacing / 2),
				PaddingTop = UDim.new(0, theme.variables.spacing / 2),
			}),
		}, {
			stroke = isHighlighted and e("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = theme.colors.accent.default,
				Thickness = theme.variables.borderWidth,
				Transparency = isHighlighted and 0 or 1,
			}),
		}, {
			preview = e(GridItemSurfacePreview, {
				backgroundColor = isSelected and theme.colors.accent.default
					or theme.colors.surface,
				surfaceType = props.surfaceType,
				previewRef = previewRef,
			}),

			labelContainer = e("Frame", {
				AnchorPoint = Vector2.yAxis,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = (isHighlighted and not isSelected)
						and theme.colors.accent.default
					or theme.colors.button.default,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, theme.variables.borderWidth * -2, 0, 0),
				ClipsDescendants = true,
				ZIndex = 10,
			}, {
				padding = e("UIPadding", {
					PaddingTop = UDim.new(0, theme.variables.spacing / 2),
					PaddingRight = UDim.new(0, theme.variables.spacing / 2),
					PaddingBottom = UDim.new(0, theme.variables.spacing / 2),
					PaddingLeft = UDim.new(0, theme.variables.spacing / 2),
				}),
				corners = e("UICorner", {
					CornerRadius = theme.variables.cornerRadius
						- UDim.new(0, theme.variables.borderWidth * 2),
				}),
			}, {
				label = e("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					FontFace = withFont(theme.typography.body, Enum.FontWeight.Bold),
					Position = UDim2.fromScale(0, 0),
					Size = UDim2.fromScale(1, 0),
					Text = formatEnumName(props.surfaceType),
					TextColor3 = (isHighlighted and not isSelected)
							and theme.colors.onAccent.default
						or theme.colors.onButton.default,
					TextSize = theme.variables.textSize,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),
			}),
		}),
	})
end

return memo(SurfacePickerGridItem)
