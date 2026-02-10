local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DropTables = require(ReplicatedStorage.Shared.Config.DropTables)
local PlayerStateService = require(script.Parent.PlayerStateService)

local RewardService = {}

local EXP_GOLD_LEVEL_RANGE = 10

local damageByMonster = {}

local function getMonsterRewardData(monster)
	if not monster then
		return nil
	end

	local configId = monster:GetAttribute("ConfigId")
	if type(configId) ~= "string" or configId == "" then
		return nil
	end

	local exp = tonumber(monster:GetAttribute("RewardExp")) or 0
	local gold = tonumber(monster:GetAttribute("RewardGold")) or 0
	local boneChance = tonumber(monster:GetAttribute("RewardBoneChance")) or 0
	local dropTable = monster:GetAttribute("RewardDropTable")
	local monsterType = monster:GetAttribute("MonsterType")
	local monsterLevel = tonumber(monster:GetAttribute("Level")) or 1
	local lastHitBonePercent = tonumber(monster:GetAttribute("RewardLastHitBonePercent")) or 0.3
	local damageContributionPercent = tonumber(monster:GetAttribute("RewardDamageContributionPercent")) or 0.7

	return {
		ConfigId = configId,
		Exp = exp,
		Gold = gold,
		BoneChance = boneChance,
		DropTable = dropTable,
		Type = monsterType,
		Level = monsterLevel,
		LastHitBonePercent = lastHitBonePercent,
		DamageContributionPercent = damageContributionPercent,
	}
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
	local rewardData = getMonsterRewardData(monster)
	if not rewardData then
		return
	end

	local isBoss = rewardData.Type == "Boss"

	local lastHitId = monster:GetAttribute("LastHitPlayerId")
	local lastHitPlayer = lastHitId and Players:GetPlayerByUserId(lastHitId)

	if lastHitPlayer then
		local playerLevel = getPlayerLevel(lastHitPlayer)
		if withinLevelRange(playerLevel, rewardData.Level) then
			PlayerStateService:AddExp(lastHitPlayer, rewardData.Exp)
			PlayerStateService:AddGold(lastHitPlayer, rewardData.Gold)
		end
		grantDrops(lastHitPlayer, rewardData.DropTable)
	end

	if rewardData.BoneChance > 0 and math.random() <= rewardData.BoneChance then
		local damageEntry = damageByMonster[monster]
		local baseBone = 1
		if isBoss and damageEntry and damageEntry.total > 0 then
			for userId, damage in pairs(damageEntry.byPlayer) do
				local player = Players:GetPlayerByUserId(userId)
				if player then
					local share = (damage / damageEntry.total) * rewardData.DamageContributionPercent
					if lastHitId and userId == lastHitId then
						share += rewardData.LastHitBonePercent
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
