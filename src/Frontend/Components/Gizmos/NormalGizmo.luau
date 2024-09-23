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

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Right and 1 or -1

	local topSize = sizeZ
	local topCframe = CFrame.new(side * x, y, 0)
	local topVisible = true

	local leftSize = sizeY
	local leftCframe = CFrame.new(side * x, 0, side * z)
	local leftVisible = true

	local rightSize = sizeY
	local rightCframe = CFrame.new(side * x, 0, -side * z)
	local rightVisible = true

	if props.part:IsA("WedgePart") then
		local hypotenuse = math.sqrt(size.Y ^ 2 + size.Z ^ 2)

		topSize =
			Vector3.new(LINE_THICKNESS, LINE_THICKNESS, hypotenuse + LINE_THICKNESS)
		topCframe = CFrame.new(side * x, 0, 0)
			* CFrame.Angles(-math.atan2(size.Y, size.Z), 0, 0)

		leftVisible = side == 1
		rightVisible = side == -1
	elseif props.part:IsA("CornerWedgePart") then
		topVisible = false

		if side == -1 then
			local bottomRightPoint = CFrame.new(-x, -y, z).Position
			local bottomLeftPoint = CFrame.new(-x, -y, -z).Position
			local topLeftPoint = CFrame.new(x, y, -z).Position

			local topLeftBottomLeftMidpoint = (topLeftPoint + bottomLeftPoint) / 2
			local topLeftBottomRightMidpoint = (topLeftPoint + bottomRightPoint) / 2

			leftSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topLeftPoint - bottomLeftPoint).Magnitude + LINE_THICKNESS
			)

			leftCframe = CFrame.lookAt(topLeftBottomLeftMidpoint, topLeftPoint)

			rightSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topLeftPoint - bottomRightPoint).Magnitude + LINE_THICKNESS
			)

			rightCframe = CFrame.lookAt(topLeftBottomRightMidpoint, topLeftPoint)
		elseif side == 1 then
			local topRightPoint = CFrame.new(x, y, -z).Position
			local bottomLeftPoint = CFrame.new(x, -y, z).Position

			local topRightBottomLeftMidpoint = (topRightPoint + bottomLeftPoint) / 2

			leftSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topRightPoint - bottomLeftPoint).Magnitude + LINE_THICKNESS
			)

			leftCframe = CFrame.lookAt(topRightBottomLeftMidpoint, topRightPoint)
		end
	end

	return e("Folder", nil, {
		top = topVisible and e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = topCframe,
			Size = topSize,
			ZIndex = 2,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = CFrame.new(side * x, -y, 0),
			Size = sizeZ,
			ZIndex = 2,
		}),

		left = leftVisible and e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = 2,
		}),

		right = rightVisible and e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
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

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Back and 1 or -1

	local topVisible = true

	local leftSize = sizeY
	local leftCframe = CFrame.new(-side * x, 0, side * z)

	local rightSize = sizeY
	local rightCframe = CFrame.new(side * x, 0, side * z)

	if props.part:IsA("CornerWedgePart") then
		topVisible = false

		if side == 1 then
			local bottomRightPoint = CFrame.new(x, -y, z).Position
			local bottomLeftPoint = CFrame.new(-x, -y, z).Position
			local topLeftPoint = CFrame.new(x, y, -z).Position

			local topLeftBottomLeftMidpoint = (topLeftPoint + bottomLeftPoint) / 2
			local topLeftBottomRightMidpoint = (topLeftPoint + bottomRightPoint) / 2

			leftSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topLeftPoint - bottomLeftPoint).Magnitude + LINE_THICKNESS
			)

			leftCframe = CFrame.lookAt(topLeftBottomLeftMidpoint, topLeftPoint)

			rightSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topLeftPoint - bottomRightPoint).Magnitude + LINE_THICKNESS
			)

			rightCframe = CFrame.lookAt(topLeftBottomRightMidpoint, topLeftPoint)
		elseif side == -1 then
			local topLeftPoint = CFrame.new(x, y, -z).Position
			local bottomRightPoint = CFrame.new(-x, -y, -z).Position

			local topLeftBottomRightMidpoint = (topLeftPoint + bottomRightPoint) / 2

			rightSize = Vector3.new(
				LINE_THICKNESS,
				LINE_THICKNESS,
				(topLeftPoint - bottomRightPoint).Magnitude + LINE_THICKNESS
			)

			rightCframe = CFrame.lookAt(topLeftBottomRightMidpoint, topLeftPoint)
		end
	end

	return e("Folder", nil, {
		top = topVisible and e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = CFrame.new(0, y, side * z),
			Size = sizeX,
			ZIndex = 2,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = CFrame.new(0, -y, side * z),
			Size = sizeX,
			ZIndex = 2,
		}),

		left = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = 2,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
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

	if props.part:IsA("CornerWedgePart") and props.normal == Enum.NormalId.Top then
		return
	end

	local size = props.part.Size

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local side = props.normal == Enum.NormalId.Bottom and -1 or 1

	local backSize = sizeX
	local backCframe = CFrame.new(0, side * y, -z)

	local leftSize = sizeZ
	local leftCframe = CFrame.new(-x, side * y, 0)

	local rightSize = sizeZ
	local rightCframe = CFrame.new(x, side * y, 0)

	if props.part:IsA("WedgePart") and side == 1 then
		local hypotenuse = math.sqrt(size.Y ^ 2 + size.Z ^ 2)
		local angle = math.atan2(size.Y, size.Z)

		backCframe = CFrame.new(0, -y, -z)

		leftSize =
			Vector3.new(LINE_THICKNESS, LINE_THICKNESS, hypotenuse + LINE_THICKNESS)
		leftCframe = CFrame.new(-x, 0, 0) * CFrame.Angles(-angle, 0, 0)

		rightSize =
			Vector3.new(LINE_THICKNESS, LINE_THICKNESS, hypotenuse + LINE_THICKNESS)
		rightCframe = CFrame.new(x, 0, 0) * CFrame.Angles(-angle, 0, 0)
	end

	return e("Folder", nil, {
		left = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = 2,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
			ZIndex = 2,
		}),

		front = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = CFrame.new(0, side * y, z),
			Size = sizeX,
			ZIndex = 2,
		}),

		back = e("BoxHandleAdornment", {
			Adornee = props.part,
			Color3 = props.color,
			CFrame = backCframe,
			Size = backSize,
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
