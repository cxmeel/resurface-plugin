--!strict
local generateUuid = require("./generateUuid")

local function shortUuid(uuid: string?)
	if uuid then
		return uuid:sub(1, 7)
	end

	return shortUuid(generateUuid())
end

return shortUuid
