local useEffect = require("@pkgs/React").useEffect
local useLatest = require("./useLatest")

local function useEvent<T...>(
	event: RBXScriptSignal<T...>?,
	callback: (T...) -> ()?,
	options: {
		once: boolean?,
		connected: boolean?,
	}?
)
	local callbackRef = useLatest(callback)

	local once = options and options.once or false
	local connected = if options and options.connected ~= nil
		then options.connected
		else true

	useEffect(function()
		if not event or not callback or not connected then
			return
		end

		local connection: RBXScriptConnection
		local method = once and "Once" or "Connect"

		connection = event[method](event, function(...)
			if connection.Connected and callbackRef.current then
				callbackRef.current(...)
			end
		end)

		return function()
			if connection.Connected then
				connection:Disconnect()
			end
		end
	end, { event, callback ~= nil, connected } :: { any })
end

return useEvent
