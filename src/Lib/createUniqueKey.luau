local function createUniqueKey(existingNames: { any }?)
	local names = {}

	if existingNames then
		for _, name in existingNames do
			local stringified = tostring(name)

			if names[stringified] == nil then
				names[stringified] = 1
			else
				names[stringified] += 1
			end
		end
	end

	return function(name: any): string
		name = tostring(name)

		if names[name] == nil then
			names[name] = 1
			return name
		end

		while true do
			names[name] += 1
			local finalName = `{name}_{names[name]}`

			if names[finalName] == nil then
				return finalName
			end
		end
	end
end

return createUniqueKey
