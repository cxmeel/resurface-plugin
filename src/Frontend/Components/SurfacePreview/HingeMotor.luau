local React = require("@pkgs/React")

local e = React.createElement

local HINGE_PART_COLOR = BrickColor.Yellow().Color
local BASE_PART_COLOR = BrickColor.Gray().Color

local function HingeMotor(props: {
	isMotor: boolean,
	cframe: CFrame?,
})
	local hingePartRef = React.createRef() :: { current: Part? }

	return e("Model", {
		PrimaryPart = hingePartRef.current,
	}, {
		base = props.isMotor and e("Part", {
			Anchored = true,
			Massless = true,
			CanTouch = false,
			CanQuery = false,
			CanCollide = false,
			Shape = Enum.PartType.Cylinder,
			BottomSurface = Enum.SurfaceType.Smooth,
			CastShadow = false,
			Color = BASE_PART_COLOR,
			Material = Enum.Material.SmoothPlastic,
			CFrame = props.cframe,
			Rotation = Vector3.new(0, 0, -90),
			Size = Vector3.new(0.3, 0.8, 0.8),
			TopSurface = Enum.SurfaceType.Smooth,
		}),

		hinge = e("Part", {
			ref = hingePartRef,
			Anchored = true,
			Massless = true,
			CanTouch = false,
			CanQuery = false,
			CanCollide = false,
			Shape = Enum.PartType.Cylinder,
			BottomSurface = Enum.SurfaceType.Smooth,
			BrickColor = BrickColor.Yellow(),
			CastShadow = false,
			Color = HINGE_PART_COLOR,
			Material = Enum.Material.SmoothPlastic,
			CFrame = props.cframe,
			Rotation = Vector3.new(0, 0, -90),
			Size = Vector3.new(1, 0.4, 0.4),
			TopSurface = Enum.SurfaceType.Smooth,
		}),
	})
end

return HingeMotor
