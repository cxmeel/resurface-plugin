local ChangeHistoryService = game:GetService("ChangeHistoryService")
local MaterialService = game:GetService("MaterialService")

local MaterialVariants = require("@root/Assets/MaterialVariants")

local createUniqueKey = require("@root/Lib/createUniqueKey")

local NORMAL_IDS: { Enum.NormalId } = Enum.NormalId:GetEnumItems()

local SURFACE_NORMAL_MAP = {
	[Enum.NormalId.Top] = "TopSurface",
	[Enum.NormalId.Bottom] = "BottomSurface",
	[Enum.NormalId.Left] = "LeftSurface",
	[Enum.NormalId.Right] = "RightSurface",
	[Enum.NormalId.Front] = "FrontSurface",
	[Enum.NormalId.Back] = "BackSurface",
}

local SURFACE_NO_VARIANTS = {
	[Enum.SurfaceType.Smooth] = true,
	[Enum.SurfaceType.SmoothNoOutlines] = true,
	[Enum.SurfaceType.SteppingMotor] = true,
	[Enum.SurfaceType.Motor] = true,
}

local function findExistingMaterialVariant(
	variant: MaterialVariants.Variant
): MaterialVariant?
	for _, object in MaterialService:GetDescendants() do
		if object:IsA("MaterialVariant") then
			if object.ColorMap ~= variant.colorMap then
				continue
			end

			if object.NormalMap ~= variant.normalMap then
				continue
			end

			if object.StudsPerTile ~= variant.studsPerTile then
				continue
			end

			return object
		end
	end

	return
end

local function getMaterialVariant(surfaceType: Enum.SurfaceType): MaterialVariant?
	local materialVariant

	for _, variant in MaterialVariants do
		if variant.surfaceType == surfaceType then
			materialVariant = variant
			break
		end
	end

	if not materialVariant then
		return
	end

	local existingVariant = findExistingMaterialVariant(materialVariant)

	if existingVariant then
		return existingVariant
	end

	local existingVariantNames = {}

	for _, variant in MaterialService:GetChildren() do
		table.insert(existingVariantNames, variant.Name)
	end

	local uniqueName = createUniqueKey(existingVariantNames)

	local newVariant = Instance.new("MaterialVariant")
	newVariant.Name = uniqueName(surfaceType.Name)
	newVariant.BaseMaterial = Enum.Material.Plastic
	newVariant.ColorMap = materialVariant.colorMap
	newVariant.NormalMap = materialVariant.normalMap
	newVariant.StudsPerTile = materialVariant.studsPerTile
	newVariant.Parent = MaterialService

	return newVariant
end

local function extractBaseParts(objects: { Instance })
	local partMap = {}
	local count = 0

	for _, object in objects do
		if object == workspace or object == workspace.Terrain then
			continue
		end

		if object:IsA("BasePart") then
			if not partMap[object] then
				partMap[object] = true
				count += 1
			end

			continue
		end

		if object:IsA("Folder") or object:IsA("PVInstance") then
			local descendants = object:GetDescendants()

			for _, descendant in descendants do
				if descendant:IsA("BasePart") then
					if not partMap[descendant] then
						partMap[descendant] = true
						count += 1
					end
				end
			end
		end
	end

	return partMap, count
end

local function containsAllNormalIds(array: { Enum.NormalId }?)
	if not array then
		return false
	end

	for _, normalId in NORMAL_IDS do
		if not table.find(array, normalId) then
			return false
		end
	end

	return true
end

local function pluralize(word: string, count: number)
	if count == 1 or word:sub(-1):lower() == "s" then
		return word
	end

	return `{word}s`
end

local function resetAllSurfaces(
	part: BasePart,
	props: {
		material: Enum.Material?,
		surfaceType: Enum.SurfaceType?,
	}?
)
	local material = props and props.material or Enum.Material.Plastic
	local surfaceType = props and props.surfaceType or Enum.SurfaceType.Smooth

	part.Material = material
	part.MaterialVariant = ""

	for _, normal in NORMAL_IDS do
		local property = SURFACE_NORMAL_MAP[normal];
		(part :: any)[property] = surfaceType
	end
end

local function apply(
	objects: { Instance },
	props: {
		surfaceType: Enum.SurfaceType,
		normalIds: { Enum.NormalId }?,
		useMaterialVariants: boolean?,
		useMaterialVariantsMeshUnion: boolean?,
		setMaterialToPlastic: boolean?,
	}
)
	local normalIds: { Enum.NormalId } = props.normalIds or NORMAL_IDS
	local partMap, partCount = extractBaseParts(objects)

	if #normalIds == 0 or partCount == 0 then
		return
	end

	local useMaterialVariants = props.useMaterialVariants
	local useMaterialVariantsMeshUnion = props.useMaterialVariantsMeshUnion
	local setMaterialToPlastic = props.setMaterialToPlastic

	local applyAllFaces = normalIds == NORMAL_IDS or containsAllNormalIds(normalIds)

	local ok, recordingId = pcall(function()
		return ChangeHistoryService:TryBeginRecording(
			`apply surface "{props.surfaceType.Name}" to {partCount} {pluralize(
				"part",
				partCount
			)}`
		)
	end)

	if not ok or not recordingId then
		error(
			`[Resurface] ChangeHistoryService failed to provide a recording id{recordingId and `: {recordingId}` or ""}.`
		)
	end

	for part in partMap do
		if applyAllFaces then
			local processMaterialVariants = useMaterialVariants

			if part:IsA("TriangleMeshPart") and not useMaterialVariants then
				processMaterialVariants = useMaterialVariantsMeshUnion
			end

			if processMaterialVariants then
				if SURFACE_NO_VARIANTS[props.surfaceType] then
					local isNoOutlines = props.surfaceType
						== Enum.SurfaceType.SmoothNoOutlines

					resetAllSurfaces(part, {
						material = isNoOutlines and Enum.Material.SmoothPlastic
							or Enum.Material.Plastic,
						surfaceType = isNoOutlines
								and Enum.SurfaceType.SmoothNoOutlines
							or Enum.SurfaceType.Smooth,
					})

					continue
				end

				local materialVariant = getMaterialVariant(props.surfaceType)

				if materialVariant then
					resetAllSurfaces(part, {
						material = materialVariant.BaseMaterial,
						surfaceType = Enum.SurfaceType.Smooth,
					})

					part.MaterialVariant = materialVariant.Name
				end

				continue
			end
		end

		if part:IsA("TriangleMeshPart") then
			continue
		end

		if setMaterialToPlastic then
			part.Material = Enum.Material.Plastic
			part.MaterialVariant = ""
		end

		for _, normal in normalIds do
			local property = SURFACE_NORMAL_MAP[normal];
			(part :: any)[property] = props.surfaceType
		end
	end

	ChangeHistoryService:FinishRecording(
		recordingId,
		Enum.FinishRecordingOperation.Commit
	)
end

return {
	apply = apply,
}
