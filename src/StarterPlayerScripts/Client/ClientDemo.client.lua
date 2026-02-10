local Players = game:GetService("Players")

local clientRoot = script.Parent:WaitForChild("Client")
local ClientState = require(clientRoot:WaitForChild("ClientState"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RuntimeStatsDemoGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "StatsContainer"
container.Size = UDim2.fromOffset(240, 92)
container.Position = UDim2.fromOffset(16, 16)
container.BackgroundTransparency = 0.25
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = container

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
uiList.VerticalAlignment = Enum.VerticalAlignment.Center
uiList.Parent = container

local function createLabel(name)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, -16, 0, 36)
	label.Position = UDim2.fromOffset(8, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = container
	return label
end

local goldLabel = createLabel("GoldLabel")
local expLabel = createLabel("ExpLabel")

local function render(snapshot)
	goldLabel.Text = string.format("Gold: %d", tonumber(snapshot.Gold) or 0)
	expLabel.Text = string.format("Exp: %d", tonumber(snapshot.Exp) or 0)
end

render(ClientState:GetSnapshot())
ClientState:Subscribe(render)
