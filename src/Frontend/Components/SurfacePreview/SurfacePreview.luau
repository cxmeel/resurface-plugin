local plugin: Plugin = script:FindFirstAncestorOfClass("Plugin")

local React = require("@pkgs/React")

local HingeMotor = require("./HingeMotor")

local useDefaultProps = require("../../Hooks/useDefaultProps")
local useMemo = React.useMemo

local createUniqueKey = require("../../../Lib/createUniqueKey")
local e = React.createElement
local memo = React.memo

local PREVIEW_CAMERA = Instance.new("Camera")
PREVIEW_CAMERA.CFrame = CFrame.fromOrientation(-math.pi / 2, 0, 0) * CFrame.new(0, 0, 5)

local PSEUDO_HINGE_PROPS = {
	[Enum.SurfaceType.Hinge] = { isMotor = false },
	[Enum.SurfaceType.Motor] = { isMotor = true },
	[Enum.SurfaceType.SteppingMotor] = { isMotor = true },
}

export type RefApi = {
	updateCursorOffset: (cursorOffset: Vector2) -> (),
	revertCursorOffset: () -> (),
}

if plugin then
	PREVIEW_CAMERA.Name = "SurfacePreviewCamera"
	PREVIEW_CAMERA.Parent = plugin
end

local function SurfacePreviewLarge(props: {
	surfaceType: Enum.SurfaceType,
	partCframe: (CFrame | any)?,
	native: { [string]: any }?,
})
	local pseudoHingeProps = PSEUDO_HINGE_PROPS[props.surfaceType]

	local rootElementProps = useDefaultProps({
		Ambient = Color3.new(),
		LightColor = Color3.new(1, 1, 1),
		LightDirection = Vector3.new(0, -3, 5),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 1,
		CurrentCamera = PREVIEW_CAMERA,
		Size = UDim2.fromOffset(24, 24),
	}, props.native)

	local pseudoHinges = useMemo(function()
		local children: React.Node = {}

		if not pseudoHingeProps then
			return children
		end

		local uniqueKey = createUniqueKey()

		for x = 0, 180, 90 do
			for y = 0, 180, 90 do
				local hingeTransform = CFrame.fromOrientation(
					math.rad(x - 90),
					math.rad(y),
					0
				) * CFrame.new(0, 2.5, 0) * CFrame.fromOrientation(
					0,
					0,
					math.pi / 2
				)

				local hingeCframe = hingeTransform

				if typeof(props.partCframe) == "table" then
					hingeCframe = props.partCframe:map(function(cframe: CFrame)
						return cframe * hingeTransform
					end)
				elseif typeof(props.partCframe) == "CFrame" then
					hingeCframe = props.partCframe * hingeTransform
				end

				(children :: any)[uniqueKey("pseudoHinge")] = e(HingeMotor, {
					isMotor = pseudoHingeProps.isMotor,
					cframe = hingeCframe,
				})
			end
		end

		return children
	end, { props.partCframe, props.surfaceType } :: { any })

	return e("ViewportFrame", rootElementProps, {
		aspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			DominantAxis = Enum.DominantAxis.Height,
		}),
	}, {
		part = e("Part", {
			CastShadow = false,
			Color = Color3.new(1, 1, 1),
			Material = Enum.Material.Plastic,
			CFrame = props.partCframe
				or CFrame.fromOrientation(math.pi / 2, math.pi, 0),
			Size = Vector3.one * 5,
			Shape = Enum.PartType.Ball,
			BackSurface = props.surfaceType,
			BottomSurface = props.surfaceType,
			FrontSurface = props.surfaceType,
			LeftSurface = props.surfaceType,
			RightSurface = props.surfaceType,
			TopSurface = props.surfaceType,
		}, pseudoHinges),
	})
end

return (memo(SurfacePreviewLarge) :: never) :: typeof(SurfacePreviewLarge)
