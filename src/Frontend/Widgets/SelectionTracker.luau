local Selection = game:GetService("Selection")
local UserInputService = game:GetService("UserInputService")

local React = require("@pkgs/React")

local ResurfaceApi = require("@root/ResurfaceApi")

local LocalStore = require("@root/Stores/LocalStore")
local Preferences = require("@root/Stores/Preferences")

local NormalGizmo = require("../Components/Gizmos/NormalGizmo")
local PartGizmo = require("../Components/Gizmos/PartGizmo")

local useValue = require("@root/Lib/Store").useValue
local useEvent = require("../Hooks/useEvent")
local useTheme = require("../Hooks/useTheme")
local useCallback = React.useCallback
local useEffect = React.useEffect
local useState = React.useState

local e = React.createElement

local NORMAL_MAP = {
	[Vector3.yAxis] = Enum.NormalId.Top,
	[-Vector3.yAxis] = Enum.NormalId.Bottom,
	[Vector3.xAxis] = Enum.NormalId.Right,
	[-Vector3.xAxis] = Enum.NormalId.Left,
	[-Vector3.zAxis] = Enum.NormalId.Front,
	[Vector3.zAxis] = Enum.NormalId.Back,
}

local RAYCAST_PARAMS = RaycastParams.new()
RAYCAST_PARAMS.BruteForceAllSlow = false
RAYCAST_PARAMS.CollisionGroup = "StudioSelectable"
RAYCAST_PARAMS.IgnoreWater = true
RAYCAST_PARAMS.RespectCanCollide = true

local function containsActionableSelection(selection: { Instance }?, iterated: boolean?)
	if selection then
		for _, object in selection do
			if object == workspace or object == workspace.Terrain then
				continue
			end

			if object:IsA("PVInstance") then
				return true
			end

			if not iterated and object:IsA("Folder") then
				return containsActionableSelection(object:GetDescendants(), true)
			end
		end
	end

	return false
end

local function SelectionTracker()
	local theme = useTheme()

	local isPluginActive = useValue(LocalStore.isPluginActive)
	local applyToAllFaces = useValue(Preferences.applyToAllfaces)
	local applyToAllFacesOverride = useValue(LocalStore.applyToAllfacesOverride)

	local targetPart, setTargetPart: any = useState(nil :: BasePart?)
	local targetNormal, setTargetNormal: any = useState(nil :: Enum.NormalId?)

	local isApplyToAllFaces = if applyToAllFacesOverride
		then not applyToAllFaces
		else applyToAllFaces

	local onClickCallback = useCallback(function()
		ResurfaceApi.apply({ targetPart }, {
			normalIds = if isApplyToAllFaces then nil else { targetNormal },
			surfaceType = Preferences.selectedSurface(),
			useMaterialVariants = Preferences.useMaterialVariants(),
			useMaterialVariantsMeshUnion = Preferences.useMaterialVariantsMeshUnion(),
			setMaterialToPlastic = Preferences.setMaterialToPlastic(),
		})

		if Preferences.deactivatePluginAfterOperation() then
			LocalStore.isPluginActive(false)
		end
	end, { targetPart, targetNormal, isApplyToAllFaces })

	useEffect(function()
		if not isPluginActive then
			setTargetPart(nil)
			return
		end

		local hasActionableSelection = containsActionableSelection(Selection:Get())
		LocalStore.hasActionableSelection(hasActionableSelection)
	end, { isPluginActive })

	useEvent(Selection.SelectionChanged, function()
		local hasActionableSelection = containsActionableSelection(Selection:Get())
		LocalStore.hasActionableSelection(hasActionableSelection)
	end, {
		connected = isPluginActive,
	})

	useEvent(UserInputService.InputEnded, function(inputObject, gameProcessed)
		if
			not gameProcessed
			and inputObject.UserInputType == Enum.UserInputType.MouseButton1
		then
			onClickCallback()
		end
	end, {
		connected = isPluginActive,
	})

	useEvent(UserInputService.InputChanged, function(inputObject, gameProcessed)
		if
			gameProcessed
			or inputObject.UserInputType ~= Enum.UserInputType.MouseMovement
		then
			return
		end

		local camera = workspace.CurrentCamera
		local mouseRay =
			camera:ViewportPointToRay(inputObject.Position.X, inputObject.Position.Y)

		local result = workspace:Raycast(
			mouseRay.Origin,
			mouseRay.Direction * 2048,
			RAYCAST_PARAMS
		)

		local isValidTarget = result
			and result.Instance:IsA("BasePart")
			and not result.Instance.Locked

		if not isValidTarget then
			setTargetPart(nil)
			setTargetNormal(nil)

			return
		end

		local target: BasePart = result.Instance
		local normal = target.CFrame:VectorToObjectSpace(result.Normal)

		if normal then
			local top = math.floor(normal:Dot(Vector3.yAxis) + 0.5)
			local right = math.floor(normal:Dot(Vector3.xAxis) + 0.5)
			local front = math.floor(normal:Dot(Vector3.zAxis) + 0.5)

			if top == 1 then
				normal = Vector3.yAxis
			elseif top == -1 then
				normal = -Vector3.yAxis
			end

			if right == 1 then
				normal = Vector3.xAxis
			elseif right == -1 then
				normal = -Vector3.xAxis
			end

			if front == 1 then
				normal = Vector3.zAxis
			elseif front == -1 then
				normal = -Vector3.zAxis
			end
		end

		local isWedge = target:IsA("WedgePart")

		if target:IsA("Part") and target.Shape == Enum.PartType.Wedge then
			isWedge = true
		end

		if isWedge and normal == Vector3.yAxis then
			normal = -Vector3.zAxis
		end

		setTargetPart(target)
		setTargetNormal(NORMAL_MAP[normal])
	end, {
		connected = isPluginActive,
	})

	if not isPluginActive or not targetPart then
		return
	end

	if isApplyToAllFaces then
		return e(PartGizmo, {
			part = targetPart,
			color = theme.colors.accent.default,
		})
	end

	return e(NormalGizmo, {
		normal = targetNormal,
		part = targetPart,
		color = theme.colors.accent.default,
	})
end

return SelectionTracker
