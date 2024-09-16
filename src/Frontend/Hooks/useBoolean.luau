local React = require("@pkgs/React")

local useState = React.useState
local useCallback = React.useCallback

local function useBoolean(initialValue: boolean?)
	local value, setValue = useState(initialValue or false)

	local setEnabled = useCallback(function()
		setValue(true)
	end, {})

	local setDisabled = useCallback(function()
		setValue(false)
	end, {})

	local toggleValue = useCallback(function()
		setValue(function(currentValue)
			return not currentValue
		end)
	end, {})

	return {
		value = value,
		enable = setEnabled,
		disable = setDisabled,
		toggle = toggleValue,
		set = setValue,
	}
end

return useBoolean
