local HttpService = game:GetService("HttpService")

local function createShortUuid(length: number?)
	local uuid = HttpService:GenerateGUID(false)
	return uuid:sub(1, length and math.max(1, length) or 7):lower()
end

return createShortUuid
