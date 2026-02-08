local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Progression = require(ReplicatedStorage.Shared.Config.Progression)

local Remotes = ReplicatedStorage.Shared:FindFirstChild("Remotes")
local StateUpdate = Remotes and Remotes:FindFirstChild("StateUpdate")

local PlayerStateService = {}
PlayerStateService.States = {}
PlayerStateService._connections = {}

local STAT_POINTS_PER_LEVEL = 1
local ALLOCATED_MULTIPLIERS = {
    Strength = { Damage = 1 },
    Vitality = { MaxHP = 5 },
    Agility = { MoveSpeed = 0.1 },
}

local function getLevelConfig(level)
    return Progression.Levels[level]
end

local function buildBaseStats(levelConfig)
    return {
        MaxHP = levelConfig.MaxHP,
        Damage = levelConfig.Damage,
        Defense = levelConfig.Defense,
        MoveSpeed = levelConfig.MoveSpeed,
    }
end

local function cloneStats(stats)
    return {
        MaxHP = stats.MaxHP or 0,
        Damage = stats.Damage or 0,
        Defense = stats.Defense or 0,
        MoveSpeed = stats.MoveSpeed or 0,
    }
end

local function applyStatDelta(stats, delta)
    if not delta then
        return
    end
    for statName, value in pairs(delta) do
        stats[statName] = (stats[statName] or 0) + (tonumber(value) or 0)
    end
end

local function applyAllocatedStats(stats, allocated)
    for allocatedName, amount in pairs(allocated or {}) do
        local multipliers = ALLOCATED_MULTIPLIERS[allocatedName]
        if multipliers then
            for statName, multiplier in pairs(multipliers) do
                stats[statName] = (stats[statName] or 0) + (tonumber(amount) or 0) * multiplier
            end
        end
    end
end

local function buildFinalStats(state)
    local baseStats = state.BaseStats or {}
    local finalStats = cloneStats(baseStats)
    applyAllocatedStats(finalStats, state.AllocatedStats)
    applyStatDelta(finalStats, state.EquipmentStats)
    applyStatDelta(finalStats, state.BuffStats)
    return finalStats
end

local function getValueObjectValue(container, name, fallback)
    if not container then
        return fallback
    end
    local valueObject = container:FindFirstChild(name)
    if valueObject and valueObject:IsA("ValueBase") then
        return valueObject.Value
    end
    return fallback
end

local function snapshotContainer(container)
    if not container then
        return nil
    end
    local snapshot = {}
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Folder") then
            snapshot[child.Name] = snapshotContainer(child)
        elseif child:IsA("ValueBase") then
            snapshot[child.Name] = child.Value
        end
    end
    return snapshot
end

local function snapshotState(player, state)
    local data = player and player:FindFirstChild("Data")
    local inventory = data and data:FindFirstChild("Inventory")
    local pet = data and data:FindFirstChild("Pet")

    return {
        Level = getValueObjectValue(data, "Level", state.Level),
        Exp = getValueObjectValue(data, "Exp", state.Exp),
        Gold = getValueObjectValue(data, "Gold", state.Gold),
        StatPoints = state.StatPoints,
        AllocatedStats = {
            Strength = state.AllocatedStats.Strength,
            Vitality = state.AllocatedStats.Vitality,
            Agility = state.AllocatedStats.Agility,
        },
        Stats = {
            MaxHP = state.FinalStats.MaxHP,
            Damage = state.FinalStats.Damage,
            Defense = state.FinalStats.Defense,
            MoveSpeed = state.FinalStats.MoveSpeed,
        },
        Inventory = snapshotContainer(inventory) or {},
        Pet = snapshotContainer(pet) or {},
        Cooldowns = {
            Attack = state.Cooldowns.Attack,
        },
        AutoFarm = {
            Enabled = state.AutoFarm.Enabled,
            CurrentTarget = state.AutoFarm.CurrentTarget and state.AutoFarm.CurrentTarget.Name or nil,
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
        StatPoints = 0,
        BaseStats = buildBaseStats(levelConfig),
        AllocatedStats = {
            Strength = 0,
            Vitality = 0,
            Agility = 0,
        },
        EquipmentStats = {},
        BuffStats = {},
        FinalStats = {},
        Cooldowns = {
            Attack = 0,
        },
        AutoFarm = {
            Enabled = false,
            CurrentTarget = nil,
        },
    }

    state.FinalStats = buildFinalStats(state)

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

    state.FinalStats = buildFinalStats(state)
    StateUpdate:FireClient(player, snapshotState(player, state))
end

function PlayerStateService:_trackValueObject(player, valueObject)
    if not valueObject or not valueObject:IsA("ValueBase") then
        return
    end
    local connections = self._connections[player]
    if not connections then
        connections = {}
        self._connections[player] = connections
    end
    table.insert(connections, valueObject.Changed:Connect(function()
        self:Replicate(player)
    end))
end

function PlayerStateService:_trackContainer(player, container)
    if not container or not container:IsA("Folder") then
        return
    end

    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Folder") then
            self:_trackContainer(player, child)
        elseif child:IsA("ValueBase") then
            self:_trackValueObject(player, child)
        end
    end

    local connections = self._connections[player]
    if not connections then
        connections = {}
        self._connections[player] = connections
    end

    table.insert(connections, container.ChildAdded:Connect(function(child)
        if child:IsA("Folder") then
            self:_trackContainer(player, child)
        elseif child:IsA("ValueBase") then
            self:_trackValueObject(player, child)
        end
        self:Replicate(player)
    end))

    table.insert(connections, container.ChildRemoved:Connect(function()
        self:Replicate(player)
    end))
end

function PlayerStateService:_trackData(player, data)
    if not data then
        return
    end

    self:_trackValueObject(player, data:FindFirstChild("Gold"))
    self:_trackValueObject(player, data:FindFirstChild("Exp"))
    self:_trackValueObject(player, data:FindFirstChild("Level"))
    self:_trackValueObject(player, data:FindFirstChild("StatPoints"))
    self:_trackContainer(player, data:FindFirstChild("AllocatedStats"))
    self:_trackContainer(player, data:FindFirstChild("Inventory"))
    self:_trackContainer(player, data:FindFirstChild("Pet"))
end

local function setValueObject(container, name, value)
    if not container then
        return
    end
    local valueObject = container:FindFirstChild(name)
    if valueObject and valueObject:IsA("ValueBase") then
        valueObject.Value = value
    end
end

function PlayerStateService:SyncProgressionValues(player)
    local data = player and player:FindFirstChild("Data")
    if not data then
        return
    end
    local state = self:GetState(player)
    if not state then
        return
    end

    setValueObject(data, "Level", state.Level)
    setValueObject(data, "Exp", state.Exp)
    setValueObject(data, "Gold", state.Gold)
    setValueObject(data, "StatPoints", state.StatPoints)
    local allocated = data:FindFirstChild("AllocatedStats")
    if allocated then
        setValueObject(allocated, "Strength", state.AllocatedStats.Strength)
        setValueObject(allocated, "Vitality", state.AllocatedStats.Vitality)
        setValueObject(allocated, "Agility", state.AllocatedStats.Agility)
    end
end

function PlayerStateService:_trackPlayer(player)
    local connections = self._connections[player]
    if connections then
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end
    self._connections[player] = {}

    self:_trackData(player, player:FindFirstChild("Data"))

    table.insert(self._connections[player], player.ChildAdded:Connect(function(child)
        if child.Name == "Data" then
            self:_trackData(player, child)
            self:Replicate(player)
        end
    end))
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

    self:SyncProgressionValues(player)
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
    self:SyncProgressionValues(player)
    self:Replicate(player)
end

function PlayerStateService:AddStatPoints(player, amount)
    local state = self:GetState(player)
    if not state then
        return
    end
    local gain = tonumber(amount) or 0
    if gain == 0 then
        return
    end
    state.StatPoints = math.max(0, state.StatPoints + gain)
    self:SyncProgressionValues(player)
    self:Replicate(player)
end

function PlayerStateService:AllocateStats(player, allocation)
    local state = self:GetState(player)
    if not state then
        return false
    end
    local strength = math.max(0, tonumber(allocation.Strength) or 0)
    local vitality = math.max(0, tonumber(allocation.Vitality) or 0)
    local agility = math.max(0, tonumber(allocation.Agility) or 0)
    local totalSpend = strength + vitality + agility
    if totalSpend <= 0 or totalSpend > state.StatPoints then
        return false
    end

    state.StatPoints -= totalSpend
    state.AllocatedStats.Strength += strength
    state.AllocatedStats.Vitality += vitality
    state.AllocatedStats.Agility += agility

    self:SyncProgressionValues(player)
    self:Replicate(player)
    return true
end

function PlayerStateService:ApplyBuff(player, stats, duration)
    local state = self:GetState(player)
    if not state then
        return
    end
    local applied = {}
    for statName, value in pairs(stats or {}) do
        local delta = tonumber(value) or 0
        if delta ~= 0 then
            state.BuffStats[statName] = (state.BuffStats[statName] or 0) + delta
            applied[statName] = delta
        end
    end
    self:Replicate(player)

    if duration and duration > 0 then
        task.delay(duration, function()
            local currentState = self:GetState(player)
            if not currentState then
                return
            end
            for statName, value in pairs(applied) do
                currentState.BuffStats[statName] = (currentState.BuffStats[statName] or 0) - value
            end
            self:Replicate(player)
        end)
    end
end

function PlayerStateService:SetEquippedWeapon(player, weaponId, weaponStats)
    local state = self:GetState(player)
    if not state then
        return
    end
    state.EquipmentStats = weaponStats or {}
    player:SetAttribute("EquippedWeaponId", weaponId)
    self:Replicate(player)
end

function PlayerStateService:Rebirth(player)
    local state = self:GetState(player)
    if not state then
        return
    end
    state.Exp = 0
    self:SyncProgressionValues(player)
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
    state.BaseStats = buildBaseStats(nextLevelConfig)
    state.StatPoints += STAT_POINTS_PER_LEVEL
    self:SyncProgressionValues(player)
    self:Replicate(player)
end

Players.PlayerRemoving:Connect(function(player)
    PlayerStateService.States[player] = nil
    local connections = PlayerStateService._connections[player]
    if connections then
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
    end
    PlayerStateService._connections[player] = nil
end)

Players.PlayerAdded:Connect(function(player)
    PlayerStateService:GetState(player)
    PlayerStateService:_trackPlayer(player)
    PlayerStateService:Replicate(player)
end)

return PlayerStateService
