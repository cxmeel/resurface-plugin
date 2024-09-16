local Plugin = plugin or script:FindFirstAncestorOfClass("Plugin") :: Plugin
local React = require("@pkgs/React")

local createContext = React.createContext

local pluginContext = createContext(Plugin)
local pluginToolbarContext = createContext((nil :: never) :: PluginToolbar)

return {
	plugin = pluginContext,
	pluginToolbar = pluginToolbarContext,
}
