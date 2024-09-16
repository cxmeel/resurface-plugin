local React = require("@pkgs/React")

local useMemo = React.useMemo
local useRef = React.useRef

type Predicate<T = unknown> = (a: T?, b: T) -> boolean

local function isStrictEqual(a: unknown?, b: unknown)
	return a == b
end

local function useLatest<T>(value: T, predicate: Predicate<T>?): { current: T }
	local ref = useRef(value)

	useMemo(function()
		local predicateFn: Predicate<T> = predicate or isStrictEqual

		if not predicateFn(ref.current, value) then
			ref.current = value
		end
	end, { value })

	return ref :: { current: T }
end

return useLatest
