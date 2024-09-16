local plugin: Plugin = plugin or script:FindFirstAncestorOfClass("Plugin")

local StudioService = game:GetService("StudioService")
local RuntimeScript = script.Parent.Parent.Parent

local React = require("@pkgs/React")

local LocalStore = require("@root/Stores/LocalStore")
local Manifest = require("@root/Manifest")
local Preferences = require("@root/Stores/Preferences")

local Button = require("../Components/Button")
local ComponentGroup = require("../Components/ComponentGroup")
local Divider = require("../Components/Divider")
local Popover = require("../Components/Popover")
local Switch = require("../Components/Switch")

local useDefaultProps = require("../Hooks/useDefaultProps")
local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")

local createNextOrder = require("../Lib/createNextOrder")
local createUniqueKey = require("../../Lib/createUniqueKey")
local formatEnumName = require("../Lib/formatEnumName")
local withFont = require("../Lib/withFont")
local e = React.createElement
local memo = React.memo

local studioUserId = StudioService:GetUserId()
local buildSessionId = RuntimeScript:GetAttribute("BuildSessionId")
local sourceCommitHash = RuntimeScript:GetAttribute("SourceCommitHash")
local isLocalPlugin = plugin.Parent or plugin.Name:match("%.rbxmx?$")
local pluginSource = isLocalPlugin and "model_file" or "creator_store"

local function ControlGroup(props: {
	title: string,
	description: string?,
	disabled: boolean?,
	native: { [string]: any }?,
	children: React.Node?,
})
	local theme = useTheme()
	local nextOrder = createNextOrder()

	local nativeProps = useDefaultProps({
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
	}, props.native)

	return e(ComponentGroup, {
		orientation = "horizontal",
		spacing = UDim.new(0, theme.variables.spacing * 3),
		native = nativeProps,
		layoutNative = {
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		},
	}, {
		control = props.children and e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
		}, props.children),

		labels = e(ComponentGroup, {
			orientation = "vertical",
			spacing = UDim.new(),
			native = {
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = nextOrder(),
				Size = UDim2.fromScale(1, 0),
			},
		}, {
			title = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, theme.variables.textSize),
				LayoutOrder = nextOrder(),
				FontFace = withFont(theme.typography.body, Enum.FontWeight.SemiBold),
				Text = props.title,
				TextColor3 = props.disabled and theme.colors.onSurfaceVariant
					or theme.colors.onSurface,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),

			description = props.description and e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, theme.variables.textSize),
				LayoutOrder = nextOrder(),
				FontFace = theme.typography.body,
				Text = props.description,
				TextColor3 = theme.colors.onSurfaceVariant,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
	})
end

local function SettingsWidget(props: {
	anchorRef: { current: GuiBase2d? },
})
	local theme = useTheme()

	local nextOrder = createNextOrder()
	local uniqueKey = createUniqueKey()

	local selectedSurface = useValue(Preferences.selectedSurface)
	local applyToAllfaces = useValue(Preferences.applyToAllfaces)
	local applyToAllfacesOverride = useValue(LocalStore.applyToAllfacesOverride)

	local setMaterialToPlastic = useValue(Preferences.setMaterialToPlastic)
	-- local useTextures = useValue(Preferences.useTextures)
	local useMaterialVariants = useValue(Preferences.useMaterialVariants)
	local useMaterialVariantsMeshUnion =
		useValue(Preferences.useMaterialVariantsMeshUnion)

	local deactivatePluginAfterOperation =
		useValue(Preferences.deactivatePluginAfterOperation)
	local useClassicMenuOnLaunch = useValue(Preferences.useClassicMenuOnLaunch)
	local autoFocusSurfacePickerSearch =
		useValue(Preferences.autoFocusSurfacePickerSearch)

	local isReducedMotion = useValue(Preferences.isReducedMotion)
	local transparencyScale = useValue(Preferences.transparencyScale)
	local useBounceAnimations = useValue(Preferences.useBounceAnimations)

	local isVisible = useValue(LocalStore.currentWidget) == "settings"

	local selectedSurfaceTitle = selectedSurface
			and formatEnumName(selectedSurface.Name)
		or "undefined"
	local isAllFacesEnabled = if applyToAllfacesOverride
		then not applyToAllfaces
		else applyToAllfaces

	return e(Popover, {
		visible = isVisible,
		anchorRef = props.anchorRef,
		stickyHeader = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
			FontFace = withFont(theme.typography.title, Enum.FontWeight.ExtraBold),
			Text = "Settings",
			TextColor3 = theme.colors.onSurface,
			TextSize = theme.variables.textSize * 1.25,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}) :: never,
	}, {
		layout = e("UIListLayout", {
			Padding = UDim.new(0, theme.variables.spacing),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}),
		padding = e("UIPadding", {
			PaddingRight = UDim.new(
				0,
				theme.variables.scrollbarWidth + theme.variables.spacing
			),
		}),
	}, {
		selection = e(ComponentGroup, {
			orientation = "vertical",
			spacing = UDim.new(0, theme.variables.spacing),
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			heading = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = withFont(theme.typography.title, Enum.FontWeight.ExtraBold),
				Text = "Selection",
				TextColor3 = theme.colors.onSurface,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
			}),

			allFaces = e(ControlGroup, {
				title = "Apply All Faces",
				description = `Click a part to apply "{selectedSurfaceTitle}" to all of its faces while active.`,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = isAllFacesEnabled,
					disabled = applyToAllfacesOverride,
					onClick = function()
						Preferences.applyToAllfaces(function(current)
							return not current
						end)
					end,
				}),
			}),

			useMaterialVariants = e(ControlGroup, {
				title = "Use MaterialVariants",
				description = "Emulate surface inputs on all faces by using a MaterialVariant.",
				disabled = not isAllFacesEnabled,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = useMaterialVariants,
					disabled = not isAllFacesEnabled,
					onClick = function()
						Preferences.useMaterialVariants(function(current)
							return not current
						end)
					end,
				}),
			}),

			useMaterialVariantsMeshUnion = e(ControlGroup, {
				title = "Force MaterialVariants for Meshes and Unions",
				description = 'Apply MaterialVariants to Meshes and Unions, regardless of the "Use Material Variants" setting.',
				disabled = not isAllFacesEnabled,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = useMaterialVariantsMeshUnion,
					disabled = not isAllFacesEnabled,
					onClick = function()
						Preferences.useMaterialVariantsMeshUnion(function(current)
							return not current
						end)
					end,
				}),
			}),

			setPlastic = e(ControlGroup, {
				title = "Set to Plastic",
				description = "Set the selected part's material to Plastic when applying surface inputs.",
				disabled = isAllFacesEnabled and useMaterialVariants,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = setMaterialToPlastic,
					disabled = isAllFacesEnabled and useMaterialVariants,
					onClick = function()
						Preferences.setMaterialToPlastic(function(current)
							return not current
						end)
					end,
				}),
			}),

			-- 	useTextures = e(ControlGroup, {
			-- 		title = "Always Use Textures",
			-- 		description = "Always emulate surface inputs by applying texture instances to the selected part's surface.",
			-- 		disabled = isAllFacesEnabled and useMaterialVariants,
			-- 		native = {
			-- 			LayoutOrder = nextOrder(),
			-- 		},
			-- 	}, {
			-- 		switch = e(Switch, {
			-- 			selected = useTextures,
			-- 			disabled = isAllFacesEnabled and useMaterialVariants,
			-- 			onClick = function()
			-- 				Preferences.useTextures(function(current)
			-- 					return not current
			-- 				end)
			-- 			end,
			-- 		}),
			-- 	}),
		}),

		-- General options
		[uniqueKey("divider")] = e(Divider, {
			orientation = "horizontal",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		general = e(ComponentGroup, {
			orientation = "vertical",
			spacing = UDim.new(0, theme.variables.spacing),
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			heading = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = withFont(theme.typography.title, Enum.FontWeight.ExtraBold),
				Text = "General",
				TextColor3 = theme.colors.onSurface,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
			}),

			autofocusSurfacePickerSearch = e(ControlGroup, {
				title = "Auto-focus Search",
				description = "Automatically focus the search field when opening the surface picker.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = autoFocusSurfacePickerSearch,
					onClick = function()
						Preferences.autoFocusSurfacePickerSearch(function(current)
							return not current
						end)
					end,
				}),
			}),

			classicLaunchMenu = e(ControlGroup, {
				title = "Classic Menu on Launch",
				description = "Show the classic surface picker menu from Surface Tool when clicking the plugin button.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = useClassicMenuOnLaunch,
					onClick = function()
						Preferences.useClassicMenuOnLaunch(function(current)
							return not current
						end)
					end,
				}),
			}),

			closeAfterOperation = e(ControlGroup, {
				title = "Close After Operation",
				description = "Automatically deactivate the plugin after applying a surface.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = deactivatePluginAfterOperation,
					onClick = function()
						Preferences.deactivatePluginAfterOperation(function(current)
							return not current
						end)
					end,
				}),
			}),
		}),

		-- Accessibility options
		[uniqueKey("divider")] = e(Divider, {
			orientation = "horizontal",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		accessibility = e(ComponentGroup, {
			orientation = "vertical",
			spacing = UDim.new(0, theme.variables.spacing),
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			heading = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = withFont(theme.typography.title, Enum.FontWeight.ExtraBold),
				Text = "Accessibility",
				TextColor3 = theme.colors.onSurface,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
			}),

			bounceAnimations = e(ControlGroup, {
				title = "Bounce Animations",
				description = "Use playful springy animations throughout the UI (glitchy!).",
				disabled = isReducedMotion,
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = useBounceAnimations,
					disabled = isReducedMotion,
					onClick = function()
						Preferences.useBounceAnimations(function(current)
							return not current
						end)
					end,
				}),
			}),

			reducedMotion = e(ControlGroup, {
				title = "Reduce Motion",
				description = "Reduce motion during animations.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = isReducedMotion,
					onClick = function()
						Preferences.isReducedMotion(function(current)
							return not current
						end)
					end,
				}),
			}),

			reducedTransparency = e(ControlGroup, {
				title = "Reduce Transparency",
				description = "Reduce transparency throughout the UI.",
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				switch = e(Switch, {
					selected = transparencyScale ~= 1,
					onClick = function()
						Preferences.transparencyScale(function(current)
							return current == 1 and 0 or 1
						end)
					end,
				}),
			}),
		}),

		-- Diagnostics
		[uniqueKey("divider")] = e(Divider, {
			orientation = "horizontal",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		diagnostics = e(ComponentGroup, {
			orientation = "vertical",
			spacing = UDim.new(0, theme.variables.spacing),
			native = {
				LayoutOrder = nextOrder(),
			},
		}, {
			heading = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = nextOrder(),
				FontFace = withFont(theme.typography.title, Enum.FontWeight.ExtraBold),
				Text = "Diagnostics",
				TextColor3 = theme.colors.onSurface,
				TextSize = theme.variables.textSize,
				TextWrapped = true,
			}),

			version = e(ControlGroup, {
				title = "Version",
				description = `{Manifest.package.version}{sourceCommitHash and `+{sourceCommitHash
					:sub(1, 7)
					:lower()}` or ""}{buildSessionId and " (DEV)" or " (PROD)"}`,
				native = {
					LayoutOrder = nextOrder(),
				},
			}),

			userId = studioUserId and e(ControlGroup, {
				title = "User ID",
				description = studioUserId,
				native = {
					LayoutOrder = nextOrder(),
				},
			}),

			acquisitionSource = e(ControlGroup, {
				title = "Acquisition Source",
				description = pluginSource == "creator_store" and "Creator Store"
					or "Model file",
				native = {
					LayoutOrder = nextOrder(),
				},
			}),
		}),

		-- Footer
		[uniqueKey("divider")] = e(Divider, {
			orientation = "horizontal",
			native = {
				LayoutOrder = nextOrder(),
			},
		}) :: never,

		footer = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = nextOrder(),
		}, {
			resetAllSettings = e(Button, {
				text = "Reset All Settings",
				native = {
					LayoutOrder = nextOrder(),
				},
				onClick = function()
					for _, preference in pairs(Preferences) do
						preference.reset()
					end

					LocalStore.currentWidget(nil)
				end,
			}),
		}),
	})
end

return (memo(SettingsWidget) :: never) :: typeof(SettingsWidget)
