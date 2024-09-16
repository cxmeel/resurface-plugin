local function trim(str: string): string
	local trimmed = str:gsub("^%s*(.-)%s*$", "%1")
	return trimmed
end

return trim
