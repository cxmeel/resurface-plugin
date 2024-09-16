local HttpService = game:GetService("HttpService")

local React = require("@pkgs/React")

local Icon = require("../Icon")

local useDpiScale = require("../../Hooks/useDpiScale")
local usePlugin = require("./StudioPlugin").usePlugin
local useEffect = React.useEffect

local createUniqueKey = require("../.../Lib/createUniqueKey")

local function StudioPluginMenu(props: {
	visible: boolean?,
	items: {
		{
			divider: boolean?,
		} & {
			text: string,
			icon: Icon.IconContent?,
			onClick: (() -> ())?,
		}
	}?,
})
	local plugin = usePlugin()
	local dpiScale = useDpiScale()

	useEffect(function()
		if not plugin or not props.visible or not props.items then
			return
		end

		local uniqueKey = createUniqueKey()
		local baseMenu = plugin:CreatePluginMenu(HttpService:GenerateGUID(false))
		local actions = {}

		for _, item in props.items do
			if item.divider then
				baseMenu:AddSeparator()
				continue
			end

			local icon

			if item.icon then
				local iconProps = typeof(item.icon) == "function"
						and item.icon(dpiScale)
					or item.icon

				if typeof(iconProps) == "string" then
					icon = { Image = iconProps } :: Icon.TarmacImage
				end
			end

			local action = baseMenu:AddNewAction(
				uniqueKey(item.text),
				item.text,
				icon and icon.Image or nil
			)

			if item.onClick then
				action.Triggered:Connect(function()
					item.onClick()
				end)
			end

			table.insert(actions, action)
		end

		local thread = task.spawn(function()
			baseMenu:ShowAsync()
		end)

		return function()
			task.cancel(thread)
			baseMenu:Destroy()

			for _, action in actions do
				action:Destroy()
			end
		end
	end, { props.visible })

	return
end

return StudioPluginMenu
