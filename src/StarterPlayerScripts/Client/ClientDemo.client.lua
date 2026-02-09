local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- PlayerStateService/RewardService cập nhật Currency dưới player.Data (ValueObject) và tự replicate.
-- Script này đọc Gold từ player.Data theo data flow hiện tại (không tạo remote mới).
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GoldLabelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local label = Instance.new("TextLabel")
label.Name = "GoldLabel"
label.Size = UDim2.fromOffset(200, 40)
label.Position = UDim2.fromOffset(16, 16)
label.BackgroundTransparency = 0.3
label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Text = "Gold: 0"
label.Parent = screenGui

local goldConnection

local function updateLabel(value)
	label.Text = string.format("Gold: %d", tonumber(value) or 0)
end

local function connectGoldValue(goldValue)
	if goldConnection then
		goldConnection:Disconnect()
		goldConnection = nil
	end

	if goldValue and goldValue:IsA("ValueBase") then
		updateLabel(goldValue.Value)
		goldConnection = goldValue.Changed:Connect(updateLabel)
	end
end

local function onDataFolder(dataFolder)
	if not dataFolder then
		return
	end

	connectGoldValue(dataFolder:FindFirstChild("Gold"))

	dataFolder.ChildAdded:Connect(function(child)
		if child.Name == "Gold" then
			connectGoldValue(child)
		end
	end)

	dataFolder.ChildRemoved:Connect(function(child)
		if child.Name == "Gold" then
			updateLabel(0)
		end
	end)
end

onDataFolder(player:WaitForChild("Data"))

player.ChildAdded:Connect(function(child)
	if child.Name == "Data" then
		onDataFolder(child)
	end
end)