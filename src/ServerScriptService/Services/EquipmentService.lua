local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsConfig = require(ReplicatedStorage.Shared.Config.Items)
local PlayerStateService = require(script.Parent.PlayerStateService)

local EquipmentService = {}

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end

local function ensureValue(parent, name, className, value)
	local valueObject = parent:FindFirstChild(name)
	if not valueObject then
		valueObject = Instance.new(className)
		valueObject.Name = name
		valueObject.Parent = parent
	end
	if value ~= nil then
		valueObject.Value = value
	end
	return valueObject
end

local function readItemStats(itemFolder)
	local itemIdValue = itemFolder:FindFirstChild("ItemId")
	local itemId = itemIdValue and itemIdValue.Value
	local itemConfig = itemId and ItemsConfig.Equipment[itemId]
	if not itemConfig then
		return {}, nil
	end

	local stats = {}
	for statName, value in pairs(itemConfig.BaseStats or {}) do
		stats[statName] = (stats[statName] or 0) + value
	end

	local randomStats = itemFolder:FindFirstChild("RandomStats")
	if randomStats then
		for _, statValue in ipairs(randomStats:GetChildren()) do
			if statValue:IsA("NumberValue") then
				stats[statValue.Name] = (stats[statValue.Name] or 0) + statValue.Value
			end
		end
	end

	return stats, itemConfig.Slot
end

function EquipmentService:EnsureEquipment(player)
	local data = player:FindFirstChild("Data")
	if not data then
		return nil
	end
	local equipment = ensureFolder(data, "Equipment")
	ensureValue(equipment, "Weapon", "StringValue", "")
	ensureValue(equipment, "Armor", "StringValue", "")
	ensureValue(equipment, "Accessory", "StringValue", "")
	return equipment
end

function EquipmentService:EquipItem(player, itemUid)
	local data = player:FindFirstChild("Data")
	local inventory = data and data:FindFirstChild("Inventory")
	local items = inventory and inventory:FindFirstChild("Items")
	if not items then
		return false
	end

	local itemFolder = items:FindFirstChild(itemUid)
	if not itemFolder then
		return false
	end

	local stats, slot = readItemStats(itemFolder)
	if not slot then
		return false
	end

	local equipment = self:EnsureEquipment(player)
	local slotValue = equipment and equipment:FindFirstChild(slot)
	if slotValue and slotValue:IsA("StringValue") then
		slotValue.Value = itemUid
	end

	self:ApplyEquipmentStats(player)
	PlayerStateService:Replicate(player)
	return true
end

function EquipmentService:ApplyEquipmentStats(player)
	local data = player:FindFirstChild("Data")
	local inventory = data and data:FindFirstChild("Inventory")
	local items = inventory and inventory:FindFirstChild("Items")
	local equipment = data and data:FindFirstChild("Equipment")
	if not items or not equipment then
		return
	end

	local stats = {}
	for _, slotName in ipairs({ "Weapon", "Armor", "Accessory" }) do
		local slotValue = equipment:FindFirstChild(slotName)
		local itemUid = slotValue and slotValue.Value
		if itemUid and itemUid ~= "" then
			local itemFolder = items:FindFirstChild(itemUid)
			if itemFolder then
				local itemStats = readItemStats(itemFolder)
				for statName, value in pairs(itemStats) do
					stats[statName] = (stats[statName] or 0) + value
				end
			end
		end
	end

	PlayerStateService:SetEquipmentStats(player, stats)
end

function EquipmentService:SerializeEquipment(player)
	local data = player:FindFirstChild("Data")
	local equipment = data and data:FindFirstChild("Equipment")
	if not equipment then
		return {}
	end

	local result = {}
	for _, slotName in ipairs({ "Weapon", "Armor", "Accessory" }) do
		local slotValue = equipment:FindFirstChild(slotName)
		if slotValue and slotValue:IsA("StringValue") then
			result[slotName] = slotValue.Value
		end
	end
	return result
end

function EquipmentService:HydrateEquipment(player, equipmentData)
	local equipment = self:EnsureEquipment(player)
	if not equipment then
		return
	end
	for slotName, uid in pairs(equipmentData or {}) do
		local slotValue = equipment:FindFirstChild(slotName)
		if slotValue and slotValue:IsA("StringValue") then
			slotValue.Value = uid or ""
		end
	end
	self:ApplyEquipmentStats(player)
end

return EquipmentService
