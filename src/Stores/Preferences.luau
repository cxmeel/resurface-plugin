local Store = require("@root/Lib/Store")

local Value = Store.Value
type Value<T> = Store.Value<T>

type Keybind = Enum.KeyCode | "CTRL" | "SHIFT" | "ALT"

local sessionSyncedPreferences = {
	isReducedMotion = true,
	transparencyScale = true,
}

local store = {
	selectedSurface = Value(Enum.SurfaceType.Studs),

	applyToAllfaces = Value(false),
	setMaterialToPlastic = Value(true),

	-- useTextures = Value(false),
	useMaterialVariants = Value(true),
	useMaterialVariantsMeshUnion = Value(true),

	isSurfacePickerInListView = Value(false),
	autoFocusSurfacePickerSearch = Value(true),

	useClassicMenuOnLaunch = Value(false),
	deactivatePluginAfterOperation = Value(false),

	preferredThemeId = Value(nil) :: Value<string?>,
	useBounceAnimations = Value(true),

	isReducedMotion = Value(false),
	transparencyScale = Value(1),

	keybindSurfacePickerWidget = Value(Enum.KeyCode.B) :: Value<Keybind>,
	keybindApplyToAllFacesOverride = Value("CTRL") :: Value<Keybind>,
}

do -- Persistence
	local plugin: Plugin = plugin or script:FindFirstAncestorOfClass("Plugin")
	local RunService = game:GetService("RunService")

	local Manifest = require("@root/Manifest")

	local nextRunTimestamp = tick() + 5
	local isProcessing = false

	local function serialize(value: any)
		local valueType = typeof(value)
		local serializedValue = value
		local extraData

		if valueType == "EnumItem" then
			serializedValue = value.Name
			extraData = tostring(value.EnumType)
		elseif valueType == "table" then
			serializedValue = table.clone(value)

			for k, v in serializedValue do
				serializedValue[k] = serialize(v)
			end
		end

		return { v = serializedValue, t = valueType, x = extraData }
	end

	local function deserialize(data: { v: { v: any, t: any, x: any } })
		local valueType = data.v.t
		local serializedValue = data.v.v
		local extraData = data.v.x

		if valueType == "EnumItem" then
			return (Enum :: any)[extraData][serializedValue]
		elseif valueType == "table" then
			serializedValue = table.clone(serializedValue)

			for k, v in serializedValue do
				serializedValue[k] = deserialize(v)
			end
		end

		return serializedValue
	end

	local function toSafeString(value: string)
		local formatted = value:gsub("[^%w]", "_")
		return formatted
	end

	local keyPrefix = toSafeString(Manifest.package.name)
	local function toSafeId(id: string)
		return `{keyPrefix}__{toSafeString(id)}`
	end

	local valueChangeTimestamps = {}

	for id, value in store :: { [string]: Value<any> } do
		local safeId = toSafeId(id)
		local cachedValue = plugin:GetSetting(safeId)

		if cachedValue then
			local deserializedValue = deserialize(cachedValue)
			value(deserializedValue)
		end

		value.changed:Connect(function()
			local now = tick()

			valueChangeTimestamps[id] = now
			nextRunTimestamp = now + 5
		end)

		value.onReset = function()
			plugin:SetSetting(safeId, nil)
		end
	end

	local function doSave()
		isProcessing = true

		for id, value in store :: { [string]: Value<any> } do
			if not sessionSyncedPreferences[id] and not valueChangeTimestamps[id] then
				continue
			end

			local safeId = toSafeId(id)

			local cachedValue = plugin:GetSetting(safeId)
			local currentValue = value()

			local localValueTimestamp = valueChangeTimestamps[id]
			valueChangeTimestamps[id] = nil

			if cachedValue then
				local deserializedValue = deserialize(cachedValue)

				if deserializedValue == currentValue then
					continue
				end

				if not localValueTimestamp or cachedValue.t >= localValueTimestamp then
					if sessionSyncedPreferences[id] then
						value(deserializedValue)
					end

					continue
				end
			end

			if not cachedValue and value.initialValue == currentValue then
				continue
			end

			plugin:SetSetting(safeId, {
				v = serialize(currentValue),
				t = tick(),
			})
		end

		isProcessing = false
	end

	local updateSignal = RunService.Heartbeat:Connect(function()
		if tick() < nextRunTimestamp or isProcessing then
			return
		end

		doSave()
		nextRunTimestamp = tick() + 5
	end)

	plugin.Unloading:Connect(function()
		updateSignal:Disconnect()
		doSave()
	end)
end

do
	if store.selectedSurface() == nil then
		store.selectedSurface.reset()
	end
end

return store
