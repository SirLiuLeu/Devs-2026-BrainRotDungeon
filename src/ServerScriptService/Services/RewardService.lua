local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local DropTables = require(ReplicatedStorage.Shared.Config.DropTables)
local PlayerStateService = require(script.Parent.PlayerStateService)

local RewardService = {}

local EXP_GOLD_LEVEL_RANGE = 10

local damageByMonster = {}

local function getMonsterConfig(monster)
	if not monster then
		return nil
	end
	return Monsters[monster.Name]
		or (Monsters.DesignCatalog and Monsters.DesignCatalog[monster.Name])
		or Monsters.Default
end

local function getMonsterLevel(monster, config)
	if monster then
		local levelAttribute = monster:GetAttribute("Level")
		if typeof(levelAttribute) == "number" then
			return levelAttribute
		end
	end
	return config and config.Level or 1
end

local function withinLevelRange(playerLevel, monsterLevel)
	return math.abs((playerLevel or 0) - (monsterLevel or 0)) <= EXP_GOLD_LEVEL_RANGE
end

local function getPlayerLevel(player)
	local state = PlayerStateService:GetState(player)
	return state and state.Level or 1
end

local function grantCurrencyValue(player, name, amount)
	if not player or amount == 0 then
		return
	end
	local data = player:FindFirstChild("Data")
	if not data then
		return
	end
	local valueObject = data:FindFirstChild(name)
	if valueObject and valueObject:IsA("ValueBase") then
		valueObject.Value += amount
	end
end

local function rollDropTable(tableId)
	local dropTable = DropTables and DropTables[tableId]
	if not dropTable then
		return {}
	end
	local drops = {}
	for _, entry in ipairs(dropTable) do
		local itemId = entry.ItemId
		local chance = entry.Chance or 0
		if itemId and chance > 0 and math.random() <= chance then
			table.insert(drops, itemId)
		end
	end
	return drops
end

local function grantDrops(player, dropTableId)
	local drops = rollDropTable(dropTableId)
	if #drops == 0 then
		return
	end
	local data = player:FindFirstChild("Data")
	local inventory = data and data:FindFirstChild("Inventory")
	local items = inventory and inventory:FindFirstChild("Items")
	if not items then
		return
	end
	for _, itemId in ipairs(drops) do
		local valueObject = Instance.new("StringValue")
		valueObject.Name = itemId
		valueObject.Value = itemId
		valueObject.Parent = items
	end
end

function RewardService:TrackDamage(monster, player, amount)
	if not monster or not player then
		return
	end
	local damageEntry = damageByMonster[monster]
	if not damageEntry then
		damageEntry = { total = 0, byPlayer = {} }
		damageByMonster[monster] = damageEntry
	end
	local gain = tonumber(amount) or 0
	if gain <= 0 then
		return
	end
	damageEntry.total += gain
	damageEntry.byPlayer[player.UserId] = (damageEntry.byPlayer[player.UserId] or 0) + gain
end

function RewardService:HandleMonsterDeath(monster)
	local config = getMonsterConfig(monster)
	if not config then
		return
	end
	local rewards = config.Rewards or {}
	local isBoss = config.Type == "Boss"
	local monsterLevel = getMonsterLevel(monster, config)

	local lastHitId = monster:GetAttribute("LastHitPlayerId")
	local lastHitPlayer = lastHitId and Players:GetPlayerByUserId(lastHitId)

	if lastHitPlayer then
		local playerLevel = getPlayerLevel(lastHitPlayer)
		if withinLevelRange(playerLevel, monsterLevel) then
			PlayerStateService:AddExp(lastHitPlayer, rewards.Exp or 0)
			PlayerStateService:AddGold(lastHitPlayer, rewards.Gold or 0)
		end
		grantDrops(lastHitPlayer, rewards.DropTable)
	end

	local boneChance = rewards.BoneChance or 0
	if boneChance > 0 and math.random() <= boneChance then
		local damageEntry = damageByMonster[monster]
		local baseBone = 1
		if isBoss and damageEntry and damageEntry.total > 0 then
			local lastHitPercent = rewards.LastHitBonePercent or 0.3
			local contributionPercent = rewards.DamageContributionPercent or 0.7
			for userId, damage in pairs(damageEntry.byPlayer) do
				local player = Players:GetPlayerByUserId(userId)
				if player then
					local share = (damage / damageEntry.total) * contributionPercent
					if lastHitId and userId == lastHitId then
						share += lastHitPercent
					end
					grantCurrencyValue(player, "Bone", baseBone * share)
				end
			end
		elseif lastHitPlayer then
			grantCurrencyValue(lastHitPlayer, "Bone", baseBone)
		end
	end

	damageByMonster[monster] = nil
end

return RewardService
