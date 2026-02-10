local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local DataConfig = require(ReplicatedStorage.Shared.Data.DataConfig)
local DropResolver = require(ServerScriptService.Systems.DropResolver)
local DropTables = require(ReplicatedStorage.Shared.Config.DropTables)
local PlayerStateService = require(script.Parent.PlayerStateService)
local InventoryService = require(script.Parent.InventoryService)
local PetService = require(script.Parent.PetService)
local QuestService = require(script.Parent.QuestService)
local RoomService = require(script.Parent.RoomService)

local RewardService = {}

local EXP_GOLD_LEVEL_RANGE = DataConfig.Rules.ExpGoldLevelRange or 10
local REBIRTH_GOLD_BONUS = DataConfig.Rules.RebirthGoldBonus or 0

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

local function getRebirth(player)
	local state = PlayerStateService:GetState(player)
	return state and state.Rebirth or 0
end

local function grantGold(player, baseAmount)
	local rebirth = getRebirth(player)
	local bonusMultiplier = 1 + rebirth * REBIRTH_GOLD_BONUS
	PlayerStateService:AddGold(player, math.floor((baseAmount or 0) * bonusMultiplier))
end

local function grantExp(player, amount)
	PlayerStateService:AddExp(player, amount or 0)
end

local function grantBone(player, amount)
	PlayerStateService:AddBone(player, amount or 0)
end

local function grantDrops(player, dropTableId, rollMultiplier)
	local drops = DropResolver.Resolve(dropTableId, { RollMultiplier = rollMultiplier })
	for _, drop in ipairs(drops) do
		if drop.ItemId == "Bone" then
			grantBone(player, 1)
		elseif drop.ItemId == "Gold" then
			grantGold(player, 1)
		elseif drop.Type == "Pet" then
			PetService:AddPet(player, drop.ItemId)
		else
			InventoryService:AddItem(player, drop.ItemId, drop.Type, drop.Rarity)
		end
	end
end

function RewardService:TrackDamage(monster, player, amount)
	if not monster or not player then
		return
	end
	if not RoomService:CanInteract(player, monster) then
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

function RewardService:ClearMonster(monster)
	damageByMonster[monster] = nil
end

function RewardService:HandleMonsterDeath(monster)
	local rewardData = getMonsterRewardData(monster)
	if not rewardData then
		return
	end

	local isBoss = rewardData.Type == "Boss"

	local lastHitId = monster:GetAttribute("LastHitPlayerId")
	local lastHitPlayer = lastHitId and Players:GetPlayerByUserId(lastHitId)

	local damageEntry = damageByMonster[monster]
	if isBoss and damageEntry and damageEntry.total > 0 then
		for userId, damage in pairs(damageEntry.byPlayer) do
			local player = Players:GetPlayerByUserId(userId)
			if player and RoomService:CanInteract(player, monster) then
				local share = damage / damageEntry.total
				if withinLevelRange(getPlayerLevel(player), monsterLevel) then
					grantExp(player, math.floor((rewards.Exp or 0) * share))
					grantGold(player, math.floor((rewards.Gold or 0) * share))
				end
				grantDrops(player, rewards.DropTable, share)
				QuestService:RecordEvent(player, "KillBoss", { MonsterId = monster.Name })
			end
		end
	elseif lastHitPlayer and RoomService:CanInteract(lastHitPlayer, monster) then
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
					grantBone(player, baseBone * share)
				end
			end
		elseif lastHitPlayer then
			grantBone(lastHitPlayer, baseBone)
		end
	end

	damageByMonster[monster] = nil
end

return RewardService
