local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataConfig = require(ReplicatedStorage.Shared.Data.DataConfig)
local ItemsConfig = require(ReplicatedStorage.Shared.Config.Items)

local InventoryService = {}

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

local function randomStatValue(statName)
	if statName:find("Percent") then
		return math.random(1, 5) / 100
	end
	if statName:find("Chance") then
		return math.random(1, 5) / 100
	end
	return math.random(1, 12)
end

local function buildRandomStats(rarity)
	local rarityConfig = DataConfig.Rarity[rarity or "Common"]
	local count = rarityConfig and rarityConfig.RandomStatCount or 0
	local pool = DataConfig.RandomStatPool or {}
	if count <= 0 or #pool == 0 then
		return {}
	end

	local results = {}
	local used = {}
	for _ = 1, math.min(count, #pool) do
		local index
		repeat
			index = math.random(1, #pool)
		until not used[index]
		used[index] = true
		local statName = pool[index]
		table.insert(results, { [statName] = randomStatValue(statName) })
	end
	return results
end

local function buildItemData(itemId, rarityOverride)
	local equipment = ItemsConfig.Equipment[itemId]
	local rarity = rarityOverride or (equipment and equipment.Rarity) or "Common"

	return {
		UID = HttpService:GenerateGUID(false),
		ItemId = itemId,
		Level = 1,
		Star = 0,
		Rarity = rarity,
		RandomStats = buildRandomStats(rarity),
	}
end

local function writeRandomStats(parent, randomStats)
	local statsFolder = ensureFolder(parent, "RandomStats")
	for _, entry in ipairs(randomStats or {}) do
		for statName, value in pairs(entry) do
			ensureValue(statsFolder, statName, "NumberValue", value)
		end
	end
end

local function createItemInstance(itemsFolder, itemData)
	local itemFolder = Instance.new("Folder")
	itemFolder.Name = itemData.UID
	itemFolder.Parent = itemsFolder

	ensureValue(itemFolder, "ItemId", "StringValue", itemData.ItemId)
	ensureValue(itemFolder, "Level", "IntValue", itemData.Level)
	ensureValue(itemFolder, "Star", "IntValue", itemData.Star)
	ensureValue(itemFolder, "Rarity", "StringValue", itemData.Rarity)
	writeRandomStats(itemFolder, itemData.RandomStats)
	return itemFolder
end

function InventoryService:EnsureInventory(player)
	local data = player:FindFirstChild("Data")
	if not data then
		return nil
	end
	local inventory = ensureFolder(data, "Inventory")
	ensureFolder(inventory, "Items")
	ensureFolder(inventory, "Stacks")
	ensureValue(inventory, "Capacity", "IntValue", 30)
	return inventory
end

function InventoryService:AddItem(player, itemId, itemType, rarityOverride)
	local inventory = self:EnsureInventory(player)
	if not inventory then
		return nil
	end
	local itemsFolder = inventory:FindFirstChild("Items")
	local stacksFolder = inventory:FindFirstChild("Stacks")

	local itemConfig = ItemsConfig.Equipment[itemId]
	local isEquipment = itemType == "Equipment" or itemConfig ~= nil
	if isEquipment then
		local itemData = buildItemData(itemId, rarityOverride)
		createItemInstance(itemsFolder, itemData)
		return itemData
	end

	if stacksFolder then
		local stack = ensureValue(stacksFolder, itemId, "IntValue", 0)
		stack.Value += 1
	end
	return nil
end

function InventoryService:SerializeInventory(player)
	local data = player:FindFirstChild("Data")
	local inventory = data and data:FindFirstChild("Inventory")
	if not inventory then
		return { Items = {}, Capacity = 30 }
	end

	local items = {}
	local itemsFolder = inventory:FindFirstChild("Items")
	if itemsFolder then
		for _, itemFolder in ipairs(itemsFolder:GetChildren()) do
			if itemFolder:IsA("Folder") then
				local itemId = itemFolder:FindFirstChild("ItemId")
				local rarity = itemFolder:FindFirstChild("Rarity")
				local level = itemFolder:FindFirstChild("Level")
				local star = itemFolder:FindFirstChild("Star")
				items[itemFolder.Name] = {
					UID = itemFolder.Name,
					ItemId = itemId and itemId.Value or "",
					Rarity = rarity and rarity.Value or "Common",
					Level = level and level.Value or 1,
					Star = star and star.Value or 0,
					RandomStats = {},
				}
				local statsFolder = itemFolder:FindFirstChild("RandomStats")
				if statsFolder then
					for _, stat in ipairs(statsFolder:GetChildren()) do
						if stat:IsA("NumberValue") then
							table.insert(items[itemFolder.Name].RandomStats, { [stat.Name] = stat.Value })
						end
					end
				end
			end
		end
	end

	local capacityValue = inventory:FindFirstChild("Capacity")
	return {
		Items = items,
		Capacity = capacityValue and capacityValue.Value or 30,
	}
end

function InventoryService:HydrateInventory(player, inventoryData)
	local inventory = self:EnsureInventory(player)
	if not inventory then
		return
	end

	local capacity = inventoryData and inventoryData.Capacity
	if capacity then
		local capacityValue = inventory:FindFirstChild("Capacity")
		if capacityValue and capacityValue:IsA("IntValue") then
			capacityValue.Value = capacity
		end
	end

	local itemsFolder = inventory:FindFirstChild("Items")
	if not itemsFolder then
		return
	end
	itemsFolder:ClearAllChildren()

	for _, itemData in pairs((inventoryData and inventoryData.Items) or {}) do
		if itemData and itemData.UID then
			createItemInstance(itemsFolder, itemData)
		end
	end
end

return InventoryService
