local React = require("@pkgs/React")

local e = React.createElement

local LINE_THICKNESS = 0.15

local function BoxWireframe(props: {
	part: BasePart,
	color: Color3?,
})
	local size = props.part.Size

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local sizeX = Vector3.new(size.X + LINE_THICKNESS, LINE_THICKNESS, LINE_THICKNESS)
	local sizeY = Vector3.new(LINE_THICKNESS, size.Y + LINE_THICKNESS, LINE_THICKNESS)
	local sizeZ = Vector3.new(LINE_THICKNESS, LINE_THICKNESS, size.Z + LINE_THICKNESS)

	return e("Folder", nil, {
		topOutline = e("Folder", nil, {
			posX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(0, y, z),
				Size = sizeX,
				ZIndex = 2,
			}),
			negX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(0, y, -z),
				Size = sizeX,
				ZIndex = 2,
			}),

			posZ = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(x, y, 0),
				Size = sizeZ,
				ZIndex = 2,
			}),
			negZ = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(-x, y, 0),
				Size = sizeZ,
				ZIndex = 2,
			}),
		}),

		bottomOutline = e("Folder", nil, {
			posX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(0, -y, z),
				Size = sizeX,
				ZIndex = 2,
			}),
			negX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(0, -y, -z),
				Size = sizeX,
				ZIndex = 2,
			}),

			posZ = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(x, -y, 0),
				Size = sizeZ,
				ZIndex = 2,
			}),
			negZ = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(-x, -y, 0),
				Size = sizeZ,
				ZIndex = 2,
			}),
		}),

		cornerOutline = e("Folder", nil, {
			frontPosX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(x, 0, z),
				Size = sizeY,
				ZIndex = 2,
			}),
			frontNegX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(-x, 0, z),
				Size = sizeY,
				ZIndex = 2,
			}),

			backPosX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(x, 0, -z),
				Size = sizeY,
				ZIndex = 2,
			}),
			backNegX = e("BoxHandleAdornment", {
				Adornee = props.part,
				Color3 = props.color,
				CFrame = CFrame.new(-x, 0, -z),
				Size = sizeY,
				ZIndex = 2,
			}),
		}),
	})
end

local function PartGizmo(props: {
	part: BasePart?,
	color: Color3?,
})
	local part = props.part

	if not part then
		return
	end

	return e("Folder", nil, {
		outline = e("Highlight", {
			Adornee = props.part,
			FillTransparency = 1,
			OutlineColor = props.color,
		}),

		wireframe = e(BoxWireframe, {
			part = part,
			color = props.color,
		}),
	})
end

return PartGizmo
