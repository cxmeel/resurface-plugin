local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local ClassicMenu = require("../ClassicMenu")
local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local ContextualToolbar = require("./ContextualToolbar")
local PrimaryToolbar = require("./PrimaryToolbar")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring
local useEffect = React.useEffect

local createNextOrder = require("../Lib/createNextOrder")
local e = React.createElement
local memo = React.memo

local function ViewportWidget()
	local isPluginActive = useValue(LocalStore.isPluginActive)
	local isReducedMotion = useValue(Preferences.isReducedMotion)

	local useClassicMenuOnLaunch = useValue(Preferences.useClassicMenuOnLaunch)
	local isLegacyPluginTransition = useValue(LocalStore.isLegacyPluginTransition)

	local theme = useTheme()
	local nextOrder = createNextOrder()

	local springs, api = useSpring(function()
		return {
			alpha = isPluginActive and 1 or 0,
		}
	end)

	useEffect(function()
		local easing: any = ReactSpring.easings.easeOutBack
		local alpha = isPluginActive and 1 or 0

		if alpha == 0 then
			easing = ReactSpring.easings.easeOutQuint
		end

		local config = {
			alpha = alpha,
			config = {
				duration = isReducedMotion and 0 or 0.225,
				easing = easing,
			},
		}

		if isPluginActive and (useClassicMenuOnLaunch or isLegacyPluginTransition) then
			return ClassicMenu.show(function(action)
				if action then
					LocalStore.isLegacyPluginTransition(false)

					api.start(config)
				else
					LocalStore.isPluginActive(false)
				end
			end)
		end

		api.start(config)

		return function()
			api.stop({ "alpha" })
		end
	end, { isPluginActive })

	return e("Frame", {
		AnchorPoint = springs.alpha:map(function(alpha: number)
			return Vector2.new(0.5, 1 - alpha)
		end),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Position = springs.alpha:map(function(alpha: number)
			return UDim2.new(0.5, 0, 0, 16 * alpha)
		end),
		Visible = springs.alpha:map(function(alpha: number)
			return alpha ~= 0
		end),
	}, {
		layout = e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, theme.variables.spacing / 2),
		}),
	}, {
		scale = e("UIScale", {
			Scale = springs.alpha:map(function(alpha: number)
				return 0.8 + 0.3 * alpha
			end),
		}),
	}, {
		primaryToolbar = e(PrimaryToolbar, {
			layoutOrder = nextOrder(),
		}),
	}, {
		contextualToolbar = e(ContextualToolbar, {
			layoutOrder = nextOrder(),
		}),
	})
end

return (memo(ViewportWidget) :: never) :: typeof(ViewportWidget)
