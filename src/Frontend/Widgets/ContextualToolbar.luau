local Selection = game:GetService("Selection")

local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local ResurfaceApi = require("@root/ResurfaceApi")

local Button = require("../Components/Button")
local ContextualActionContainer = require("../Components/ContextualActionContainer")
local Tooltip = require("../Components/Tooltip")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")

local createNextOrder = require("../Lib/createNextOrder")
local e = React.createElement

local NO_MATERIAL_VARIANTS = {
	[Enum.SurfaceType.Motor] = true,
	[Enum.SurfaceType.SteppingMotor] = true,
	[Enum.SurfaceType.Hinge] = true,
}

local function ContextualToolbar()
	local nextOrder = createNextOrder()
	local theme = useTheme()

	local selectedSurface = useValue(Preferences.selectedSurface)
	local applyToAllFaces = useValue(Preferences.applyToAllfaces)
	local applyToAllFacesOverride = useValue(LocalStore.applyToAllfacesOverride)
	local useMaterialVariants = useValue(Preferences.useMaterialVariants)
	local hasActionableSelection = useValue(LocalStore.hasActionableSelection)

	local isApplyToAllFaces = if applyToAllFacesOverride
		then not applyToAllFaces
		else applyToAllFaces

	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, {
		layout = e("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, theme.variables.spacing / 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	}, {
		applyToSelection = e(ContextualActionContainer, {
			visible = isApplyToAllFaces and hasActionableSelection,
			layoutOrder = nextOrder(),
		}, {
			tooltip = e(Tooltip, {
				title = "Apply to Selection",
				text = "Apply the selected surface to all faces of the current selection.",
			}, {
				button = e(Button, {
					rounded = true,
					text = "Selection",
					icon = IconMap.Icons.target,
					onClick = function()
						local selection = Selection:Get()

						ResurfaceApi.apply(selection, {
							surfaceType = Preferences.selectedSurface(),
							useMaterialVariants = Preferences.useMaterialVariants(),
							useMaterialVariantsMeshUnion = Preferences.useMaterialVariantsMeshUnion(),
							setMaterialToPlastic = Preferences.setMaterialToPlastic(),
						})

						if Preferences.deactivatePluginAfterOperation() then
							LocalStore.isPluginActive(false)
						end
					end,
				}),
			}),
		}),

		useMaterialVariants = e(ContextualActionContainer, {
			visible = isApplyToAllFaces and not NO_MATERIAL_VARIANTS[selectedSurface],
			layoutOrder = nextOrder(),
		}, {
			tooltip = e(Tooltip, {
				title = "Use MaterialVariants",
				text = "Emulate surface inputs on all faces by using a MaterialVariant.",
			}, {
				button = e(Button, {
					rounded = true,
					selected = useMaterialVariants,
					text = "MaterialVariants",
					icon = IconMap.Icons.material,
					onClick = function()
						Preferences.useMaterialVariants(function(value)
							return not value
						end)
					end,
				}),
			}),
		}),
	})
end

return ContextualToolbar
