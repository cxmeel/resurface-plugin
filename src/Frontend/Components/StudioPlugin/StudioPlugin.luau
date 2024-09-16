local React = require("@pkgs/React")

local StudioPluginContexts = require("./StudioPluginContexts")

local e = React.createElement
local useContext = React.useContext

local function StudioPluginProvider(props: {
	plugin: Plugin,
	children: React.Node?,
})
	return e(StudioPluginContexts.plugin.Provider, {
		value = props.plugin,
	}, props.children)
end

local function useStudioPlugin()
	return useContext(StudioPluginContexts.plugin)
end

return {
	Provider = StudioPluginProvider,
	usePlugin = useStudioPlugin,
}
