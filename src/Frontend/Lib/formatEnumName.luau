local function formatEnumName(name: string | EnumItem)
	if typeof(name) == "EnumItem" then
		name = name.Name
	end

	local formatted = (name :: string):gsub("(%l)(%u)", "%1 %2")
	return formatted
end

return formatEnumName
