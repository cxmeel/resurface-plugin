local React = require("@pkgs/React")

local StudioPluginToolbar = require("./StudioPluginToolbar")

local useRef = React.useRef
local useEffect = React.useEffect

local function StudioPluginToolbarButton(props: {
	id: string,
	tooltip: string?,
	icon: string?,
	text: string?,
	enabled: boolean?,
	clickableWhenViewportHidden: boolean?,
	active: boolean?,
	onClick: () -> ()?,
})
	local pluginToolbar = StudioPluginToolbar.usePluginToolbar()
	local pluginToolbarButton = useRef(nil :: PluginToolbarButton?)

	useEffect(function()
		if pluginToolbarButton.current then
			pluginToolbarButton.current:Destroy()
			pluginToolbarButton.current = nil
		end

		local toolbarButton = pluginToolbar:CreateButton(
			props.id,
			props.tooltip or "",
			props.icon or "",
			props.text or props.id
		)

		toolbarButton.Name = `Button<{props.id}>`
		toolbarButton.Parent = pluginToolbar
		pluginToolbarButton.current = toolbarButton

		return function()
			if pluginToolbarButton.current then
				pluginToolbarButton.current:Destroy()
				pluginToolbarButton.current = nil
			end
		end
	end, { props.id })

	useEffect(function()
		if not pluginToolbarButton.current or not props.onClick then
			return
		end

		local connection = pluginToolbarButton.current.Click:Connect(props.onClick)

		return function()
			if connection and connection.Connected then
				connection:Disconnect()
			end
		end
	end, { props.id, props.onClick } :: { any })

	useEffect(function()
		if pluginToolbarButton.current then
			pluginToolbarButton.current.Icon = props.icon or ""
		end
	end, { props.icon })

	useEffect(function()
		if pluginToolbarButton.current then
			pluginToolbarButton.current.Enabled = if props.enabled
				then props.enabled
				else true
		end
	end, { props.enabled })

	useEffect(function()
		if pluginToolbarButton.current then
			pluginToolbarButton.current.ClickableWhenViewportHidden = props.clickableWhenViewportHidden
				or false
		end
	end, { props.clickableWhenViewportHidden })

	useEffect(function()
		if pluginToolbarButton.current then
			pluginToolbarButton.current:SetActive(props.active or false)
		end
	end, { props.active })

	return
end

return StudioPluginToolbarButton
