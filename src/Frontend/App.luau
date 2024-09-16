local React = require("@pkgs/React")

local PluginFacade = require("./PluginFacade")
local SelectionTracker = require("./Widgets/SelectionTracker")
local StudioPluginProvider = require("./Components/StudioPlugin/StudioPlugin").Provider
local ViewportWidget = require("./Widgets/ViewportWidget")

local e = React.createElement

local function App(props: {
	plugin: Plugin,
})
	return e(StudioPluginProvider, {
		plugin = props.plugin,
	}, {
		pluginFacade = e(PluginFacade),
		viewportWidget = e(ViewportWidget),
		selectionTracker = e(SelectionTracker),
	})
end

return App
