local UserInputService = game:GetService("UserInputService")

local Array = require("@root/Lib/Array")
local React = require("@pkgs/React")

local IconMap = require("@root/Assets/IconMap")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local Button = require("../Components/Button")
local ComponentGroup = require("../Components/ComponentGroup")
local Popover = require("../Components/Popover")
local SurfacePickerGridView = require("../Components/SurfacePickerGridView")
local SurfacePickerListView = require("../Components/SurfacePickerListView")
local TextBox = require("../Components/TextBox")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")
local useEffect = React.useEffect
local useState = React.useState
local useMemo = React.useMemo
local useRef = React.useRef

local createNextOrder = require("../Lib/createNextOrder")
local e = React.createElement

local SURFACE_TYPES: { Enum.SurfaceType } = Enum.SurfaceType:GetEnumItems()
local SURFACE_TYPE_NAMES = Array.map(SURFACE_TYPES, function(surfaceType)
	return surfaceType.Name:lower()
end)

local function calculateSearchInputInset(theme: typeof(useTheme()), numButtons: number)
	return -(
		(theme.variables.spacing * 2 + theme.variables.textSize) * numButtons
		+ (theme.variables.spacing / 2) * numButtons
	)
end

local function SurfacePickerWidget(props: {
	anchorRef: { current: GuiBase2d? },
})
	local theme = useTheme()
	local nextOrder = createNextOrder()

	local scrollingFrameRef = useRef(nil :: ScrollingFrame?)
	local textBoxRef = useRef(nil :: TextBox?)

	local isVisible = useValue(LocalStore.currentWidget) == "surfacePicker"
	local isInListView = useValue(Preferences.isSurfacePickerInListView)
	local autoFocusSurfacePickerSearch =
		useValue(Preferences.autoFocusSurfacePickerSearch)

	local searchQuery, setSearchQuery = useState("")

	local surfaceTypes: { Enum.SurfaceType } = useMemo(function()
		if searchQuery == "" then
			return SURFACE_TYPES
		end

		local surfaces = {}

		for _, surfaceType: Enum.SurfaceType in SURFACE_TYPES do
			if surfaceType.Name:lower():match(searchQuery) then
				table.insert(surfaces, surfaceType)
			end
		end

		return surfaces
	end, { searchQuery })

	local quickSelectSurfaceType = useMemo(function()
		local quickSelectItem: Enum.SurfaceType?

		if #surfaceTypes == 1 then
			quickSelectItem = surfaceTypes[1]
		end

		if not quickSelectItem then
			local exactMatchIndex = table.find(SURFACE_TYPE_NAMES, searchQuery)

			if exactMatchIndex then
				quickSelectItem = SURFACE_TYPES[exactMatchIndex]
			end
		end

		return quickSelectItem
	end, { surfaceTypes } :: { any })

	useEffect(function()
		local connection = UserInputService.InputEnded:Connect(
			function(input, robloxProcessed)
				if robloxProcessed or not isVisible then
					return
				end

				if textBoxRef.current and input.KeyCode == Enum.KeyCode.Slash then
					textBoxRef.current:CaptureFocus()
				end
			end
		)

		return function()
			connection:Disconnect()
		end
	end, { isVisible })

	return e(Popover, {
		visible = isVisible,
		anchorRef = props.anchorRef,
		scrollingFrameRef = scrollingFrameRef,
		stickyHeader = e(ComponentGroup, {
			native = {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				LayoutOrder = nextOrder(),
			},
			layoutNative = {
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			},
		}, {
			search = e(TextBox, {
				textBoxRef = textBoxRef,
				fullWidth = true,
				autofocus = autoFocusSurfacePickerSearch,
				placeholder = "Search",
				icon = IconMap.Icons.search,
				text = searchQuery,
				native = {
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = nextOrder(),
					Size = UDim2.new(1, calculateSearchInputInset(theme, 2), 0, 0),
				},
				onChange = function(_, text)
					local trimmed = text:gsub("[^%w]", "")
					setSearchQuery(trimmed:lower())
				end,
				onFocusLost = function(_, _, enterPressed)
					if not enterPressed then
						return
					end

					local selectIndex = 1

					if #surfaceTypes ~= 1 then
						local foundIndex = table.find(SURFACE_TYPE_NAMES, searchQuery)

						if not foundIndex then
							return
						end

						selectIndex = foundIndex
					end

					Preferences.selectedSurface(surfaceTypes[selectIndex])
					LocalStore.currentWidget(nil)
				end,
			}),

			viewModeToggles = e(ComponentGroup, {
				native = {
					LayoutOrder = nextOrder(),
				},
			}, {
				gridView = e(Button, {
					icon = IconMap.Icons.view_grid,
					selected = not isInListView,
					onClick = function()
						Preferences.isSurfacePickerInListView(false)
					end,
				}),

				listView = e(Button, {
					icon = IconMap.Icons.view_list,
					selected = isInListView,
					onClick = function()
						Preferences.isSurfacePickerInListView(true)
					end,
				}),
			}),
		}) :: never,
	}, {
		view = isInListView and e(SurfacePickerListView, {
			surfaceTypes = surfaceTypes,
			highlightedSurfaceType = quickSelectSurfaceType,
			scrollingFrameRef = scrollingFrameRef,
		}) or e(SurfacePickerGridView, {
			surfaceTypes = surfaceTypes,
			highlightedSurfaceType = quickSelectSurfaceType,
			scrollingFrameRef = scrollingFrameRef,
		}),
	})
end

return SurfacePickerWidget
