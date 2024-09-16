local plugin: Plugin = script:FindFirstAncestorOfClass("Plugin")

local React = require("@pkgs/React")

local HingeMotor = require("./HingeMotor")

local useDefaultProps = require("../../Hooks/useDefaultProps")
local useTheme = require("../../Hooks/useTheme")

local e = React.createElement
local memo = React.memo

local PREVIEW_CAMERA = Instance.new("Camera")
PREVIEW_CAMERA.CFrame = CFrame.fromOrientation(-math.pi / 2, 0, 0)
	* CFrame.new(0, 0, 3.5)

local COLOR_BLACK = Color3.new()
local COLOR_WHITE = Color3.new(1, 1, 1)

local PART_COLOR = COLOR_WHITE
local EMULATED_PART_COLOR = Color3.fromHex("bababa")

if plugin then
	PREVIEW_CAMERA.Name = "SurfacePreviewIconCamera"
	PREVIEW_CAMERA.Parent = plugin
end

local PSEUDO_HINGE_PROPS = {
	[Enum.SurfaceType.Hinge] = { isMotor = false },
	[Enum.SurfaceType.Motor] = { isMotor = true },
	[Enum.SurfaceType.SteppingMotor] = { isMotor = true },
}

local NO_EMULATION = {
	[Enum.SurfaceType.Smooth] = true,
	[Enum.SurfaceType.SmoothNoOutlines] = true,
}

local function SurfacePreviewIcon(props: {
	surfaceType: Enum.SurfaceType,
	cornerRadius: (UDim | false)?,
	native: { [string]: any }?,
	children: React.Node?,
})
	local pseudoHingeProps = PSEUDO_HINGE_PROPS[props.surfaceType]
	local theme = useTheme()

	local rootElementProps = useDefaultProps({
		Size = UDim2.fromOffset(24, 24),
		Ambient = COLOR_BLACK,
		LightColor = COLOR_WHITE,
		LightDirection = Vector3.new(0, -3, 5),
		BackgroundColor3 = COLOR_BLACK,
		BackgroundTransparency = 1,
		CurrentCamera = PREVIEW_CAMERA,
	}, props.native)

	if NO_EMULATION[props.surfaceType] then
		return e("Frame", {
			BackgroundColor3 = EMULATED_PART_COLOR,
			Size = rootElementProps.Size,
			LayoutOrder = rootElementProps.LayoutOrder,
		}, {
			aspectRatio = e("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Height,
			}),
			corners = props.cornerRadius ~= false and e("UICorner", {
				CornerRadius = props.cornerRadius or theme.variables.cornerRadius,
			}),
		})
	end

	return e("ViewportFrame", rootElementProps, {
		aspectRatio = e("UIAspectRatioConstraint", {
			AspectRatio = 1,
			DominantAxis = Enum.DominantAxis.Height,
		}),
		corners = props.cornerRadius ~= false and e("UICorner", {
			CornerRadius = props.cornerRadius or theme.variables.cornerRadius,
		}),
	}, {
		part = e("Part", {
			CastShadow = false,
			Color = PART_COLOR,
			CFrame = CFrame.fromOrientation(math.pi / 2, math.pi, 0),
			Size = Vector3.one * 4,
			FrontSurface = props.surfaceType,
		}),
	}, {
		pseudoHinge = pseudoHingeProps and e(HingeMotor, {
			isMotor = pseudoHingeProps.isMotor,
			cframe = CFrame.new(0, 2, 0) * CFrame.fromOrientation(0, 0, math.pi / 2),
		}),
	}, props.children)
end

return (memo(SurfacePreviewIcon) :: never) :: typeof(SurfacePreviewIcon)
