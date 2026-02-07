local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Progression = require(ReplicatedStorage.Shared.Config.Progression)

local PlayerDataService = {}
PlayerDataService.StateByPlayer = {}

local function getLevelConfig(level)
    return Progression.Levels[level] or Progression.Levels[1]
end

local function buildStats(levelConfig)
    return {
        STR = 1,
        AGI = 1,
        VIT = 1,
        MaxHP = levelConfig.MaxHP or 100,
        Damage = levelConfig.Damage or 5,
        Defense = levelConfig.Defense or 0,
        MoveSpeed = levelConfig.MoveSpeed or 16,
    }
end

local function getOrCreateFolder(player)
    local folder = player:FindFirstChild("PlayerData")
    if folder then
        return folder
    end

    folder = Instance.new("Folder")
    folder.Name = "PlayerData"
    folder.Parent = player

    local function addNumberValue(name)
        local value = Instance.new("NumberValue")
        value.Name = name
        value.Parent = folder
        return value
    end

    addNumberValue("Level")
    addNumberValue("Exp")
    addNumberValue("Gold")
    addNumberValue("Bone")
    addNumberValue("STR")
    addNumberValue("AGI")
    addNumberValue("VIT")
    addNumberValue("UpgradeLevel")

    return folder
end

local function updateFolder(player, state)
    local folder = getOrCreateFolder(player)

    local function setValue(name, value)
        local obj = folder:FindFirstChild(name)
        if obj then
            obj.Value = value
        end
    end

    setValue("Level", state.Level)
    setValue("Exp", state.Exp)
    setValue("Gold", state.Gold)
    setValue("Bone", state.Bone)
    setValue("STR", state.Stats.STR)
    setValue("AGI", state.Stats.AGI)
    setValue("VIT", state.Stats.VIT)
    setValue("UpgradeLevel", state.UpgradeLevel)
end

function PlayerDataService:GetData(player)
    if not player or not player:IsA("Player") then
        return nil
    end

    local state = self.StateByPlayer[player]
    if state then
        return state
    end

    local levelConfig = getLevelConfig(1)
    state = {
        Level = 1,
        Exp = 0,
        Gold = 0,
        Bone = 0,
        UpgradeLevel = 0,
        Stats = buildStats(levelConfig),
        Cooldowns = {
            Attack = 0,
        },
    }

    self.StateByPlayer[player] = state
    updateFolder(player, state)

    return state
end

function PlayerDataService:UpdateReplication(player)
    local state = self:GetData(player)
    if not state then
        return
    end
    updateFolder(player, state)
end

function PlayerDataService:ApplyCharacterStats(player, character)
    local state = self:GetData(player)
    if not state then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    humanoid.MaxHealth = state.Stats.MaxHP
    humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)
    humanoid.WalkSpeed = state.Stats.MoveSpeed
end

function PlayerDataService:AddExp(player, amount)
    local state = self:GetData(player)
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
        state.Exp -= expToNext
        state.Level += 1
        state.Stats = buildStats(getLevelConfig(state.Level))
    end

    self:UpdateReplication(player)
    if player.Character then
        self:ApplyCharacterStats(player, player.Character)
    end
end

function PlayerDataService:AddGold(player, amount)
    local state = self:GetData(player)
    if not state then
        return
    end

    local gain = tonumber(amount) or 0
    if gain <= 0 then
        return
    end

    state.Gold += gain
    self:UpdateReplication(player)
end

function PlayerDataService:AddBone(player, amount)
    local state = self:GetData(player)
    if not state then
        return
    end

    local gain = tonumber(amount) or 0
    if gain <= 0 then
        return
    end

    state.Bone += gain
    self:UpdateReplication(player)
end

function PlayerDataService:SpendGold(player, amount)
    local state = self:GetData(player)
    if not state then
        return false
    end

    local cost = tonumber(amount) or 0
    if cost <= 0 then
        return false
    end

    if state.Gold < cost then
        return false
    end

    state.Gold -= cost
    self:UpdateReplication(player)
    return true
end

Players.PlayerRemoving:Connect(function(player)
    PlayerDataService.StateByPlayer[player] = nil
end)

return PlayerDataService
