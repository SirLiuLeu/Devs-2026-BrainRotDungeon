local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local Remotes = ReplicatedStorage.Shared.Remotes
local UpgradeRequest = Remotes:WaitForChild("UpgradeRequest")
local UpgradeUI = Remotes:WaitForChild("UpgradeUI")

local function getUI()
    local playerGui = player:WaitForChild("PlayerGui")
    return playerGui:WaitForChild("BrainrotUI")
end

local function updateStats(labels, data)
    labels.LevelLabel.Text = string.format("Level: %d", data.Level.Value)
    labels.ExpLabel.Text = string.format("Exp: %d", data.Exp.Value)
    labels.GoldLabel.Text = string.format("Gold: %d", data.Gold.Value)
    labels.BoneLabel.Text = string.format("Bone: %d", data.Bone.Value)
    labels.STRLabel.Text = string.format("STR: %d", data.STR.Value)
    labels.AGILabel.Text = string.format("AGI: %d", data.AGI.Value)
    labels.VITLabel.Text = string.format("VIT: %d", data.VIT.Value)
end

local function bindUI()
    local ui = getUI()
    local mainFrame = ui:WaitForChild("MainFrame")
    local statsFrame = mainFrame:WaitForChild("StatsFrame")
    local equipmentFrame = mainFrame:WaitForChild("EquipmentFrame")
    local upgradeFrame = mainFrame:WaitForChild("UpgradeFrame")

    local statsTab = mainFrame:WaitForChild("StatsTabButton")
    local equipmentTab = mainFrame:WaitForChild("EquipmentTabButton")

    statsTab.MouseButton1Click:Connect(function()
        statsFrame.Visible = true
        equipmentFrame.Visible = false
    end)

    equipmentTab.MouseButton1Click:Connect(function()
        statsFrame.Visible = false
        equipmentFrame.Visible = true
    end)

    local labels = {
        LevelLabel = statsFrame:WaitForChild("LevelLabel"),
        ExpLabel = statsFrame:WaitForChild("ExpLabel"),
        GoldLabel = statsFrame:WaitForChild("GoldLabel"),
        BoneLabel = statsFrame:WaitForChild("BoneLabel"),
        STRLabel = statsFrame:WaitForChild("STRLabel"),
        AGILabel = statsFrame:WaitForChild("AGILabel"),
        VITLabel = statsFrame:WaitForChild("VITLabel"),
    }

    local data = player:WaitForChild("PlayerData")
    updateStats(labels, data)

    for _, value in ipairs(data:GetChildren()) do
        if value:IsA("NumberValue") then
            value.Changed:Connect(function()
                updateStats(labels, data)
            end)
        end
    end

    local upgradeInfo = upgradeFrame:WaitForChild("UpgradeInfo")
    local upgradeButton = upgradeFrame:WaitForChild("UpgradeButton")

    upgradeButton.MouseButton1Click:Connect(function()
        UpgradeRequest:FireServer()
    end)

    UpgradeUI.OnClientEvent:Connect(function(payload)
        upgradeFrame.Visible = true
        local level = payload.upgradeLevel or 0
        local cost = payload.nextCost or 0
        if payload.error then
            upgradeInfo.Text = string.format("Upgrade Level: %d | Cost: %d (%s)", level, cost, payload.error)
        else
            upgradeInfo.Text = string.format("Upgrade Level: %d | Cost: %d", level, cost)
        end
    end)
end

bindUI()
