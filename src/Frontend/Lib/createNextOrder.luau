local function createNextOrder(startAt: number?)
	local layoutOrder = startAt or 0

	return function()
		layoutOrder += 1
		return layoutOrder
	end
end

return createNextOrder
