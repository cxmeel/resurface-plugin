local useMemo = require("@pkgs/React").useMemo

local function merge(...)
	local result = {}

	for _, object in { ... } do
		if typeof(object) ~= "table" then
			continue
		end

		for key, value in object do
			result[key] = value
		end
	end

	return result
end

local function useDefaultProps(...)
	local args = { ... }

	local mergedProps = useMemo(function()
		return merge(unpack(args))
	end, { args })

	return mergedProps
end

return useDefaultProps
