export type Value<T> =
	((value: (T | (current: T) -> T)?, bypassSignals: boolean?) -> T)
	& {
		changed: RBXScriptSignal<T, T>,
		initialValue: T,
		destroy: () -> (),
		reset: () -> (),
		onChange: (prev: T, next: T) -> () -> (),
		onReset: (() -> ())?,
	}

local function Value<T>(
	value: T,
	api: {
		validate: ((value: T) -> boolean)?,
	}?
)
	local changedSignal = Instance.new("BindableEvent")
	local cachedValue = value

	local proxy: any
	proxy = setmetatable({
		changed = changedSignal.Event,
		initialValue = value,
		onChange = function(_, callback)
			local connection = changedSignal.Event:Connect(function(...)
				callback(...)
			end)

			return function()
				connection:Disconnect()
			end
		end,
		destroy = function()
			changedSignal:Destroy()

			changedSignal = nil :: never
			cachedValue = nil :: never
		end,
		reset = function()
			local currentValue = cachedValue
			cachedValue = value

			changedSignal:Fire(currentValue, value)

			if proxy.onReset then
				proxy.onReset()
			end
		end,
		onReset = nil :: () -> ()?,
	}, {
		__call = function(_, ...)
			if select("#", ...) == 0 then
				return cachedValue
			end

			local proposedValue = select(1, ...)

			if typeof(proposedValue) == "function" then
				proposedValue = proposedValue(cachedValue)
			end

			if cachedValue == proposedValue then
				return cachedValue
			end

			if api and api.validate and not api.validate(proposedValue) then
				return cachedValue
			end

			if select(2, ...) ~= false then
				changedSignal:Fire(cachedValue, proposedValue)
			end

			cachedValue = proposedValue
			return proposedValue
		end,
	})

	return proxy :: Value<T>
end

local hooks = {}
do
	local React = require("@pkgs/React")

	local useEffect = React.useEffect
	local useState = React.useState

	function hooks.useValue<T, V>(value: Value<T>): T
		local currentValue, setCurrentValue = useState(value())

		useEffect(function()
			local valueChanged = value.changed:Connect(function(_, newValue)
				setCurrentValue(function(current)
					if current ~= newValue then
						return newValue
					end

					return current
				end)
			end)

			return function()
				valueChanged:Disconnect()
			end
		end, { value.changed } :: { any })

		return currentValue
	end
end

return {
	Value = Value,
	useValue = hooks.useValue,
}
