local React = require("@pkgs/React")

local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local SurfacePreviewIcon = require("./SurfacePreview/SurfacePreviewIcon")

local useValue = require("@root/Lib/Store").useValue
local useBoolean = require("../Hooks/useBoolean")
local useTheme = require("../Hooks/useTheme")

local createNextOrder = require("../Lib/createNextOrder")
local formatEnumName = require("../Lib/formatEnumName")
local withFont = require("../Lib/withFont")
local e = React.createElement
local memo = React.memo

local function SurfacePickerListItem(props: {
	surfaceType: Enum.SurfaceType,
	highlighted: boolean?,
})
	local theme = useTheme()

	local nextOrder = createNextOrder()

	local isHovered = useBoolean(false)
	local isSelected = useValue(Preferences.selectedSurface) == props.surfaceType

	return e("TextButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		ClipsDescendants = true,

		[React.Event.MouseEnter] = isHovered.enable,
		[React.Event.MouseLeave] = isHovered.disable,

		[React.Event.Activated] = function()
			Preferences.selectedSurface(props.surfaceType)
			LocalStore.currentWidget(nil)
		end,
	}, {
		padding = e("UIPadding", {
			PaddingBottom = UDim.new(0, theme.variables.borderWidth),
			PaddingLeft = UDim.new(0, theme.variables.borderWidth),
			PaddingRight = UDim.new(0, theme.variables.borderWidth),
			PaddingTop = UDim.new(0, theme.variables.borderWidth),
		}),
	}, {
		container = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = isSelected and 0 or 1,
			BackgroundColor3 = isSelected and theme.colors.accent.default or nil,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
		}, {
			corners = e("UICorner", {
				CornerRadius = theme.variables.cornerRadius,
			}),
			padding = e("UIPadding", {
				PaddingBottom = UDim.new(0, theme.variables.spacing * 0.5),
				PaddingLeft = UDim.new(0, theme.variables.spacing * 0.5),
				PaddingRight = UDim.new(0, theme.variables.spacing * 0.5),
				PaddingTop = UDim.new(0, theme.variables.spacing * 0.5),
			}),
			layout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = UDim.new(0, theme.variables.spacing),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
		}, {
			stroke = (isSelected or (props.highlighted or isHovered.value))
				and e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = theme.colors.accent.default,
					Thickness = theme.variables.borderWidth,
				}),
		}, {
			icon = e(SurfacePreviewIcon, {
				surfaceType = props.surfaceType,
				cornerRadius = UDim.new(0, 3),
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				stroke = isSelected and e("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = theme.colors.onAccent.default,
					Thickness = theme.variables.borderWidth,
				}),
			}),

			text = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = withFont(
					theme.typography.body,
					isSelected and Enum.FontWeight.Bold or Enum.FontWeight.SemiBold
				),
				TextSize = theme.variables.textSize,
				Text = formatEnumName(props.surfaceType.Name),
				TextColor3 = isSelected and theme.colors.onAccent.default
					or (props.highlighted or isHovered.value) and theme.colors.accent.default
					or theme.colors.onSurface,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		}),
	})
end

return memo(SurfacePickerListItem)
