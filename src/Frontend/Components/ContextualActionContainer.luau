local React = require("@pkgs/React")
local ReactSpring = require("@pkgs/ReactSpring")

local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local useValue = require("@root/Lib/Store").useValue
local useTheme = require("../Hooks/useTheme")
local useSpring = ReactSpring.useSpring
local useEffect = React.useEffect

local e = React.createElement

local function ContextualActionContainer(props: {
	visible: boolean?,
	layoutOrder: number?,
	children: React.Node?,
})
	local theme = useTheme()

	local transparencyScale = useValue(Preferences.transparencyScale)
	local isReducedMotion = useValue(Preferences.isReducedMotion)
	local isPluginActive = useValue(LocalStore.isPluginActive)

	local isVisible = if not isPluginActive or props.visible == false
		then false
		else true

	local springs, api = useSpring(function()
		return {
			visible = isVisible and 1 or 0,
		}
	end)

	useEffect(function()
		local easing: any = ReactSpring.easings.easeOutQuint
		local alpha = isVisible and 1 or 0

		if Preferences.useBounceAnimations() then
			easing = ReactSpring.easings.easeInOutBack
		end

		api.start({
			visible = alpha,
			config = {
				duration = isReducedMotion and 0 or 0.225,
				easing = easing,
			},
		})

		return function()
			api.stop({ "visible" })
		end
	end, { isVisible })

	return e("CanvasGroup", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = theme.colors.surface,
		BackgroundTransparency = theme.variables.surfaceTransparency
			* transparencyScale,
		GroupTransparency = springs.visible:map(function(alpha: number)
			return 1 - alpha
		end),
		LayoutOrder = props.layoutOrder,
		Visible = springs.visible:map(function(alpha: number)
			return alpha ~= 0
		end),
	}, {
		padding = e("UIPadding", {
			PaddingTop = UDim.new(0, theme.variables.spacing),
			PaddingBottom = UDim.new(0, theme.variables.spacing),
			PaddingLeft = UDim.new(0, theme.variables.spacing),
			PaddingRight = UDim.new(0, theme.variables.spacing),
		}),
		corners = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	}, {
		scale = e("UIScale", {
			Scale = springs.visible:map(function(alpha: number)
				if not Preferences.useBounceAnimations() then
					return 1
				end

				return alpha
			end),
		}),
	}, props.children)
end

return ContextualActionContainer
