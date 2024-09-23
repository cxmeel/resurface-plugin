local React = require("@pkgs/React")

local e = React.createElement

local LINE_THICKNESS = 0.15
local LINE_ZINDEX = 2

local function LeftRightWirebox(props: {
	normal: Enum.NormalId,
	part: BasePart,
	color: Color3?,
})
	if props.normal ~= Enum.NormalId.Right and props.normal ~= Enum.NormalId.Left then
		return
	end

	local part = props.part
	local size = part.Size

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local side = props.normal == Enum.NormalId.Right and 1 or -1

	if part:IsA("Part") then
		if part.Shape == Enum.PartType.Ball or part.Shape == Enum.PartType.Cylinder then
			return e("CylinderHandleAdornment", {
				Color3 = props.color,
				Adornee = part,
				CFrame = CFrame.new(side * x, 0, 0)
					* CFrame.Angles(0, side * math.pi * 0.5, 0),
				Height = LINE_THICKNESS,
				InnerRadius = size.Z / 2,
				Radius = (size.Z / 2) + LINE_THICKNESS,
				ZIndex = LINE_ZINDEX,
			})
		end
	end

	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local topSize = sizeZ
	local topCframe = CFrame.new(side * x, y, 0)
	local topVisible = true

	local leftSize = sizeY
	local leftCframe = CFrame.new(side * x, 0, side * z)
	local leftVisible = true

	local rightSize = sizeY
	local rightCframe = CFrame.new(side * x, 0, -side * z)
	local rightVisible = true

	local isWedge = part:IsA("WedgePart")
	local isCornerWedge = part:IsA("CornerWedgePart")

	if part:IsA("Part") then
		isWedge = part.Shape == Enum.PartType.Wedge
		isCornerWedge = part.Shape == Enum.PartType.CornerWedge
	end

	if isWedge then
		local hypotenuse = math.sqrt(size.Y ^ 2 + size.Z ^ 2)

		topSize =
			Vector3.new(LINE_THICKNESS, LINE_THICKNESS, hypotenuse + LINE_THICKNESS)
		topCframe = CFrame.new(side * x, 0, 0)
			* CFrame.Angles(-math.atan2(size.Y, size.Z), 0, 0)

		leftVisible = side == 1
		rightVisible = side == -1
	elseif isCornerWedge then
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
			Adornee = part,
			Color3 = props.color,
			CFrame = topCframe,
			Size = topSize,
			ZIndex = LINE_ZINDEX,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = CFrame.new(side * x, -y, 0),
			Size = sizeZ,
			ZIndex = LINE_ZINDEX,
		}),

		left = leftVisible and e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = LINE_ZINDEX,
		}),

		right = rightVisible and e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
			ZIndex = LINE_ZINDEX,
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

	local part = props.part
	local size = part.Size

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local side = props.normal == Enum.NormalId.Back and 1 or -1

	if part:IsA("Part") then
		if part.Shape == Enum.PartType.Ball then
			return e("CylinderHandleAdornment", {
				Color3 = props.color,
				Adornee = part,
				CFrame = CFrame.new(0, 0, side * z),
				Height = LINE_THICKNESS,
				InnerRadius = size.Y / 2,
				Radius = (size.Y / 2) + LINE_THICKNESS,
				ZIndex = LINE_ZINDEX,
			})
		end
	end

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)

	local topVisible = true

	local leftSize = sizeY
	local leftCframe = CFrame.new(-side * x, 0, side * z)

	local rightSize = sizeY
	local rightCframe = CFrame.new(side * x, 0, side * z)

	local isCornerWedge = part:IsA("CornerWedgePart")

	if part:IsA("Part") then
		isCornerWedge = part.Shape == Enum.PartType.CornerWedge
	end

	if isCornerWedge then
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
			Adornee = part,
			Color3 = props.color,
			CFrame = CFrame.new(0, y, side * z),
			Size = sizeX,
			ZIndex = LINE_ZINDEX,
		}),

		bottom = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = CFrame.new(0, -y, side * z),
			Size = sizeX,
			ZIndex = LINE_ZINDEX,
		}),

		left = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = LINE_ZINDEX,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
			ZIndex = LINE_ZINDEX,
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

	local part = props.part

	if
		props.normal == Enum.NormalId.Top
		and (
			part:IsA("CornerWedgePart")
			or (part:IsA("Part") and part.Shape == Enum.PartType.CornerWedge)
		)
	then
		return
	end

	local size = part.Size

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local side = props.normal == Enum.NormalId.Bottom and -1 or 1

	if part:IsA("Part") then
		if part.Shape == Enum.PartType.Ball then
			return e("CylinderHandleAdornment", {
				Color3 = props.color,
				Adornee = part,
				CFrame = CFrame.new(0, side * y, 0)
					* CFrame.Angles(side * math.pi * 0.5, 0, 0),
				Height = LINE_THICKNESS,
				InnerRadius = size.Z / 2,
				Radius = (size.Z / 2) + LINE_THICKNESS,
				ZIndex = LINE_ZINDEX,
			})
		end
	end

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	local backSize = sizeX
	local backCframe = CFrame.new(0, side * y, -z)

	local leftSize = sizeZ
	local leftCframe = CFrame.new(-x, side * y, 0)

	local rightSize = sizeZ
	local rightCframe = CFrame.new(x, side * y, 0)

	local isWedge = part:IsA("WedgePart")

	if part:IsA("Part") then
		isWedge = part.Shape == Enum.PartType.Wedge
	end

	if isWedge and side == 1 then
		local topPoint = CFrame.new(0, y, z).Position
		local bottomPoint = CFrame.new(0, -y, -z).Position

		local topBottomMidpoint = (topPoint + bottomPoint) / 2

		backCframe = CFrame.new(bottomPoint)

		leftSize = Vector3.new(
			LINE_THICKNESS,
			LINE_THICKNESS,
			(topPoint - bottomPoint).Magnitude + LINE_THICKNESS
		)

		leftCframe = CFrame.new(x, 0, 0) * CFrame.lookAt(topBottomMidpoint, topPoint)

		rightSize = Vector3.new(
			LINE_THICKNESS,
			LINE_THICKNESS,
			(topPoint - bottomPoint).Magnitude + LINE_THICKNESS
		)

		rightCframe = CFrame.new(-x, 0, 0) * CFrame.lookAt(topBottomMidpoint, topPoint)
	end

	return e("Folder", nil, {
		left = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = leftCframe,
			Size = leftSize,
			ZIndex = LINE_ZINDEX,
		}),

		right = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = rightCframe,
			Size = rightSize,
			ZIndex = LINE_ZINDEX,
		}),

		front = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = CFrame.new(0, side * y, z),
			Size = sizeX,
			ZIndex = LINE_ZINDEX,
		}),

		back = e("BoxHandleAdornment", {
			Adornee = part,
			Color3 = props.color,
			CFrame = backCframe,
			Size = backSize,
			ZIndex = LINE_ZINDEX,
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
