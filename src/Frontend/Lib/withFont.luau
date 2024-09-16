local function withFont(font: Font, weight: Enum.FontWeight?, style: Enum.FontStyle?)
	if font.Weight == weight and font.Style == style then
		return font
	end

	local baseWeight = font.Weight or Enum.FontWeight.Regular
	local baseStyle = font.Style or Enum.FontStyle.Normal

	return Font.new(font.Family, weight or baseWeight, style or baseStyle)
end

return withFont
