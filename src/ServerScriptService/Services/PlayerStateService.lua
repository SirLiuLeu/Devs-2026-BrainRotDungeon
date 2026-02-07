local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Progression = require(ReplicatedStorage.Shared.Config.Progression)

local Remotes = ReplicatedStorage.Shared:FindFirstChild("Remotes")
local StateUpdate = Remotes and Remotes:FindFirstChild("StateUpdate")

local PlayerStateService = {}
PlayerStateService.States = {}

local function getLevelConfig(level)
    return Progression.Levels[level]
end

local function buildStats(levelConfig)
    return {
        MaxHP = levelConfig.MaxHP,
        Damage = levelConfig.Damage,
        Defense = levelConfig.Defense,
        MoveSpeed = levelConfig.MoveSpeed,
    }
end

local function snapshotState(state)
    return {
        Level = state.Level,
        Exp = state.Exp,
        Gold = state.Gold,
        Stats = {
            MaxHP = state.Stats.MaxHP,
            Damage = state.Stats.Damage,
            Defense = state.Stats.Defense,
            MoveSpeed = state.Stats.MoveSpeed,
        },
        Cooldowns = {
            Attack = state.Cooldowns.Attack,
        },
    }
end

function PlayerStateService:GetState(player)
    local state = self.States[player]
    if state then
        return state
    end

    local levelConfig = getLevelConfig(1)
    if not levelConfig then
        return nil
    end

    state = {
        Level = 1,
        Exp = 0,
        Gold = 0,
        Stats = buildStats(levelConfig),
        Cooldowns = {
            Attack = 0,
        },
    }

    self.States[player] = state
    return state
end

function PlayerStateService:Replicate(player)
    if not StateUpdate then
        return
    end
    local state = self:GetState(player)
    if not state then
        return
    end

    StateUpdate:FireClient(player, snapshotState(state))
end

function PlayerStateService:AddExp(player, amount)
    local state = self:GetState(player)
    if not state then
        return
    end

    local gain = tonumber(amount) or 0
    if gain <= 0 then
        return
    end

    state.Exp += gain

    while true do
        local levelConfig = getLevelConfig(state.Level)
        local expToNext = levelConfig and levelConfig.ExpToNext
        if not expToNext or expToNext <= 0 then
            break
        end
        if state.Exp < expToNext then
            break
        end
        if not getLevelConfig(state.Level + 1) then
            state.Exp = expToNext
            break
        end
        state.Exp -= expToNext
        self:LevelUp(player)
    end

    self:Replicate(player)
end

function PlayerStateService:AddGold(player, amount)
    local state = self:GetState(player)
    if not state then
        return
    end

    local gain = tonumber(amount) or 0
    if gain <= 0 then
        return
    end

    state.Gold += gain
    self:Replicate(player)
end

function PlayerStateService:LevelUp(player)
    local state = self:GetState(player)
    if not state then
        return
    end

    local nextLevelConfig = getLevelConfig(state.Level + 1)
    if not nextLevelConfig then
        return
    end

    state.Level += 1
    state.Stats = buildStats(nextLevelConfig)
    self:Replicate(player)
end

Players.PlayerRemoving:Connect(function(player)
    PlayerStateService.States[player] = nil
end)

return PlayerStateService
