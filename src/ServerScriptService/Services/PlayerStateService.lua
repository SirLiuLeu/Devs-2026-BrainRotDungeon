local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Progression = require(ReplicatedStorage.Shared.Config.Progression)

local Remotes = ReplicatedStorage.Shared:FindFirstChild("Remotes")
local StateUpdate = Remotes and Remotes:FindFirstChild("StateUpdate")

local PlayerStateService = {}
PlayerStateService.States = {}
PlayerStateService._connections = {}

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
        Stats = {
            MaxHP = state.Stats.MaxHP,
            Damage = state.Stats.Damage,
            Defense = state.Stats.Defense,
            MoveSpeed = state.Stats.MoveSpeed,
        },
        Inventory = snapshotContainer(inventory) or {},
        Pet = snapshotContainer(pet) or {},
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
    self:_trackContainer(player, data:FindFirstChild("Inventory"))
    self:_trackContainer(player, data:FindFirstChild("Pet"))
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
