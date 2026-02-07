local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(script.Parent.PlayerDataService)

local Remotes = ReplicatedStorage.Shared.Remotes
local UpgradeRequest = Remotes:WaitForChild("UpgradeRequest")
local UpgradeUI = Remotes:WaitForChild("UpgradeUI")

local HowToGrowth = require(ReplicatedStorage.Shared.Config.HowToGrowth)

local UpgradeService = {}

local BASE_COST = 200
local COST_GROWTH = 1.6
local DAMAGE_PER_LEVEL = 1

local function getUpgradeCost(nextLevel)
    local costConfig = HowToGrowth.UpgradeCost and HowToGrowth.UpgradeCost[nextLevel]
    if costConfig and costConfig.Gold then
        return costConfig.Gold
    end

    return math.floor(BASE_COST * (nextLevel ^ COST_GROWTH))
end

local function applyUpgradeStats(state)
    state.Stats.Damage = (state.Stats.Damage or 0) + DAMAGE_PER_LEVEL
end

function UpgradeService:OpenForPlayer(player)
    local state = PlayerDataService:GetData(player)
    if not state then
        return
    end

    local nextLevel = state.UpgradeLevel + 1
    local cost = getUpgradeCost(nextLevel)

    UpgradeUI:FireClient(player, {
        upgradeLevel = state.UpgradeLevel,
        nextCost = cost,
    })
end

function UpgradeService:HandleRequest(player)
    local state = PlayerDataService:GetData(player)
    if not state then
        return
    end

    local nextLevel = state.UpgradeLevel + 1
    local cost = getUpgradeCost(nextLevel)

    if not PlayerDataService:SpendGold(player, cost) then
        UpgradeUI:FireClient(player, {
            upgradeLevel = state.UpgradeLevel,
            nextCost = cost,
            error = "Not enough gold",
        })
        return
    end

    state.UpgradeLevel = nextLevel
    applyUpgradeStats(state)
    PlayerDataService:UpdateReplication(player)
    if player.Character then
        PlayerDataService:ApplyCharacterStats(player, player.Character)
    end

    UpgradeUI:FireClient(player, {
        upgradeLevel = state.UpgradeLevel,
        nextCost = getUpgradeCost(state.UpgradeLevel + 1),
    })
end

function UpgradeService:BindBlacksmith()
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then
        return
    end

    local blacksmith = npcs:FindFirstChild("Blacksmith")
    if not blacksmith then
        return
    end

    local prompt = blacksmith:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        return
    end

    prompt.Triggered:Connect(function(player)
        self:OpenForPlayer(player)
    end)
end

function UpgradeService:Start()
    UpgradeRequest.OnServerEvent:Connect(function(player)
        self:HandleRequest(player)
    end)

    self:BindBlacksmith()
end

return UpgradeService
