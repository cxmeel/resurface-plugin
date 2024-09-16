type Callback<T> = (rbx: T, input: InputObject) -> ()

local function withInputEvents(
	events: {
		hovered: ((rbx: GuiButton) -> ())?,
		pressed: ((rbx: GuiButton) -> ())?,
	},
	...: Callback<GuiButton>
)
	local callbacks = { ... }

	return function(rbx: GuiButton, input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if events.hovered then
				events.hovered(rbx)
			end
		elseif input.UserInputType.Name:match("MouseButton%d") then
			if events.pressed then
				events.pressed(rbx)
			end
		end

		for _, callback in callbacks do
			callback(rbx, input)
		end
	end
end

return withInputEvents
