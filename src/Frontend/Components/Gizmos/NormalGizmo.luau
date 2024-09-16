local React = require("@pkgs/React")

local e = React.createElement

local LINE_THICKNESS = 0.15

local function LeftRightWirebox(props: {
	normal: Enum.NormalId,
	part: BasePart,
	color: Color3?,
})
	if props.normal ~= Enum.NormalId.Right and props.normal ~= Enum.NormalId.Left then
		return
	end

	local size = props.part.Size
	local cframe = props.part.CFrame
	local origin = CFrame.new(Vector3.zero, cframe.LookVector)

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Right and 1 or -1

	return e("Folder", nil, {
		top = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(side * x, y, 0),
			Size = sizeZ,
			ZIndex = 2,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(side * x, -y, 0),
			Size = sizeZ,
			ZIndex = 2,
		}),

		left = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(side * x, 0, side * z),
			Size = sizeY,
			ZIndex = 2,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(side * x, 0, -side * z),
			Size = sizeY,
			ZIndex = 2,
		}),
	})
end

local function FrontBackWirebox(props: {
	normal: Enum.NormalId,
	part: BasePart,
	color: Color3?,
})
	if props.normal ~= Enum.NormalId.Front and props.normal ~= Enum.NormalId.Back then
		return
	end

	local size = props.part.Size
	local cframe = props.part.CFrame
	local origin = CFrame.new(Vector3.zero, cframe.LookVector)

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Back and 1 or -1

	return e("Folder", nil, {
		top = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(0, y, side * z),
			Size = sizeX,
			ZIndex = 2,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(0, -y, side * z),
			Size = sizeX,
			ZIndex = 2,
		}),

		left = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(side * x, 0, side * z),
			Size = sizeY,
			ZIndex = 2,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(-side * x, 0, side * z),
			Size = sizeY,
			ZIndex = 2,
		}),
	})
end

local function TopBottomWirebox(props: {
	normal: Enum.NormalId,
	part: BasePart,
	color: Color3?,
})
	if props.normal ~= Enum.NormalId.Top and props.normal ~= Enum.NormalId.Bottom then
		return
	end

	local size = props.part.Size
	local cframe = props.part.CFrame
	local origin = CFrame.new(Vector3.zero, cframe.LookVector)

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Bottom and -1 or 1

	return e("Folder", nil, {
		left = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(-x, side * y, 0),
			Size = sizeZ,
			ZIndex = 2,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(x, side * y, 0),
			Size = sizeZ,
			ZIndex = 2,
		}),

		front = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(0, side * y, z),
			Size = sizeX,
			ZIndex = 2,
		}),

		back = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = origin * CFrame.new(0, side * y, -z),
			Size = sizeX,
			ZIndex = 2,
		}),
	})
end

local function NormalGizmo(props: {
	part: BasePart?,
	normal: Enum.NormalId?,
	color: Color3?,
})
	if not props.part or not props.normal then
		return
	end

	return e("Folder", nil, {
		frontBackWirebox = e(FrontBackWirebox, {
			normal = props.normal,
			part = props.part,
			color = props.color,
		}),

		leftRightWirebox = e(LeftRightWirebox, {
			normal = props.normal,
			part = props.part,
			color = props.color,
		}),

		topBottomWirebox = e(TopBottomWirebox, {
			normal = props.normal,
			part = props.part,
			color = props.color,
		}),
	})
end

return NormalGizmo
