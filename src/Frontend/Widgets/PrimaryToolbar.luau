local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local Button = require("../Components/Button")
local ComponentGroup = require("../Components/ComponentGroup")
local Divider = require("../Components/Divider")
local SettingsWidget = require("../Widgets/SettingsWidget")
local SurfacePickerWidget = require("../Widgets/SurfacePickerWidget")
local SurfacePreviewIcon = require("../Components/SurfacePreview/SurfacePreviewIcon")
local Tooltip = require("../Components/Tooltip")
local WigglyUnderlineButton = require("../Components/WigglyUnderlineButton")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")
local useRef = React.useRef

local createNextOrder = require("../Lib/createNextOrder")
local createUniqueKey = require("../../Lib/createUniqueKey")
local formatEnumName = require("../Lib/formatEnumName")
local formatKeyCode = require("../Lib/formatKeyCode")
local e = React.createElement
local memo = React.memo

local function PrimaryToolbar()
	local theme = useTheme()

	local uniqueKey = createUniqueKey()
	local nextOrder = createNextOrder()

	local surfaceSelectorButtonRef = useRef(nil :: GuiBase2d?)
	local settingsButtonRef = useRef(nil :: GuiBase2d?)

	local selectedSurface = useValue(Preferences.selectedSurface)
	local applyToAllfaces = useValue(Preferences.applyToAllfaces)
	local applyToAllfacesOverride = useValue(LocalStore.applyToAllfacesOverride)
	local setMaterialToPlastic = useValue(Preferences.setMaterialToPlastic)
	local currentWidget = useValue(LocalStore.currentWidget)
	local useMaterialVariants = useValue(Preferences.useMaterialVariants)
	local useMaterialVariantsMeshUnion =
		useValue(Preferences.useMaterialVariantsMeshUnion)
	local transparencyScale = useValue(Preferences.transparencyScale)
	local applyToAllfacesOverrideKeycode =
		useValue(Preferences.keybindApplyToAllFacesOverride)
	local surfacePickerWidgetKeycode = useValue(Preferences.keybindSurfacePickerWidget)

	local selectedSurfaceTitle = formatEnumName(selectedSurface.Name)
	local isApplyToAllFaces = if applyToAllfacesOverride
		then not applyToAllfaces
		else applyToAllfaces

	return e("TextButton", {
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.colors.surface,
		BackgroundTransparency = theme.variables.surfaceTransparency
			* transparencyScale,
		BorderSizePixel = 0,
		Text = "",
	}, {
		corners = e("UICorner", {
			CornerRadius = theme.variables.cornerRadius
				+ UDim.new(0, theme.variables.spacing),
		}),
		padding = e("UIPadding", {
			PaddingTop = UDim.new(0, theme.variables.spacing),
			PaddingBottom = UDim.new(0, theme.variables.spacing),
			PaddingLeft = UDim.new(0, theme.variables.spacing * 1.5),
			PaddingRight = UDim.new(0, theme.variables.spacing),
		}),
		layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.variables.spacing),
		}),
	}, {
		surfaceSelector = e(Tooltip, {
			rootRef = surfaceSelectorButtonRef,
			title = "Active Surface",
			text = `Applies "{selectedSurfaceTitle}" during surface change operations.`,
			keycode = formatKeyCode(surfacePickerWidgetKeycode),
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			button = e(WigglyUnderlineButton, {
				text = formatEnumName(selectedSurface.Name),
				onClick = function()
					LocalStore.currentWidget(function(current)
						if current == "surfacePicker" then
							return nil
						end

						return "surfacePicker"
					end)
				end,
			}, {
				previewIcon = e(SurfacePreviewIcon, {
					surfaceType = selectedSurface,
				}),
			}),

			widget = e(SurfacePickerWidget, {
				anchorRef = surfaceSelectorButtonRef,
			}),
		}),

		[uniqueKey("divider")] = e(Divider, {
			orientation = "vertical",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		[uniqueKey("componentGroup")] = e(ComponentGroup, {
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			allFacesToggle = e(Tooltip, {
				title = "Apply to All Faces",
				text = `Click a part{useMaterialVariantsMeshUnion and ", mesh or union" or ""} to apply "{selectedSurfaceTitle}" to all of its faces while active.`,
				keycode = formatKeyCode(applyToAllfacesOverrideKeycode),
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				button = e(Button, {
					text = "All Faces",
					icon = IconMap.Icons.cube,
					selected = isApplyToAllFaces,
					onClick = function()
						Preferences.applyToAllfaces(function(current)
							return not current
						end)
					end,
					native = {
						LayoutOrder = nextOrder(),
					},
				}),
			}),

			setPlasticToggle = e(Tooltip, {
				title = "Set to Plastic",
				text = "Set the selected part's material to Plastic when applying surface inputs.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				button = e(Button, {
					text = "Set Plastic",
					icon = IconMap.Icons.fabric,
					selected = setMaterialToPlastic,
					disabled = isApplyToAllFaces and useMaterialVariants,
					onClick = function()
						Preferences.setMaterialToPlastic(function(current)
							return not current
						end)
					end,
					native = {
						LayoutOrder = nextOrder(),
					},
				}),
			}),
		}) :: never,

		[uniqueKey("divider")] = e(Divider, {
			orientation = "vertical",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		[uniqueKey("componentGroup")] = e(ComponentGroup, {
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			settingsToggle = e(Tooltip, {
				title = "Settings",
				rootRef = settingsButtonRef,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				button = e(Button, {
					icon = IconMap.Icons.settings,
					selected = currentWidget == "settings",
					onClick = function()
						LocalStore.currentWidget(function(current)
							if current == "settings" then
								return nil
							end

							return "settings"
						end)
					end,
					native = {
						LayoutOrder = nextOrder(),
					},
				}),

				widget = e(SettingsWidget, {
					anchorRef = settingsButtonRef,
				}),
			}),
		}) :: never,
	})
end

return (memo(PrimaryToolbar) :: never) :: typeof(PrimaryToolbar)
