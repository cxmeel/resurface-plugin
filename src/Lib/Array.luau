--!strict
local function filter<T>(array: { T }, predicate: (value: T, index: number) -> any): { T }
	local output = {}

	for index, value in array do
		if predicate(value, index) then
			table.insert(output, value)
		end
	end

	return output
end

local function map<T, U>(array: { T }, mapper: (value: T, index: number) -> U?): { U }
	local output = {}

	for index, value in array do
		local newValue = mapper(value, index)

		if newValue ~= nil then
			table.insert(output, newValue)
		end
	end

	return output
end

return {
	filter = filter,
	map = map,
}
