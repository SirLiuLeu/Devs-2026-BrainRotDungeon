local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local PlayerDataService = require(script.Parent.PlayerDataService)

local RewardService = {}

function RewardService:GrantRewards(monster)
    if not monster then
        return
    end

    local config = Monsters[monster.Name] or Monsters.Default
    local rewards = config.Rewards or {}
    local lastHitId = monster:GetAttribute("LastHitPlayerId")
    if not lastHitId then
        return
    end

    local player = Players:GetPlayerByUserId(lastHitId)
    if not player then
        return
    end

    if rewards.Exp then
        PlayerDataService:AddExp(player, rewards.Exp)
    end

    if rewards.Gold then
        PlayerDataService:AddGold(player, rewards.Gold)
    end

    if rewards.Bone then
        PlayerDataService:AddBone(player, rewards.Bone)
    end
end

return RewardService
