local React = require("@pkgs/React")

local StudioPlugin = require("./StudioPlugin")
local StudioPluginContexts = require("./StudioPluginContexts")

local e = React.createElement
local useContext = React.useContext
local useRef = React.useRef
local useEffect = React.useEffect

local function StudioPluginToolbarProvider(props: {
	name: string,
	children: React.Node?,
})
	local plugin = StudioPlugin.usePlugin()
	local pluginToolbar = useRef(plugin:CreateToolbar(props.name))

	useEffect(function()
		if pluginToolbar.current then
			pluginToolbar.current.Name = `PluginToolbar<{props.name}>`
			pluginToolbar.current.Parent = plugin
		end

		return function()
			if pluginToolbar.current then
				pluginToolbar.current:Destroy()
			end
		end
	end, {})

	return e(StudioPluginContexts.pluginToolbar.Provider, {
		value = pluginToolbar.current,
	}, props.children)
end

local function useStudioPluginToolbar()
	return useContext(StudioPluginContexts.pluginToolbar)
end

return {
	Provider = StudioPluginToolbarProvider,
	usePluginToolbar = useStudioPluginToolbar,
}
