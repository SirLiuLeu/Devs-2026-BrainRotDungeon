local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientState = require(script.Parent:WaitForChild("ClientState"))

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local StateUpdate = Remotes:WaitForChild("StateUpdate")

StateUpdate.OnClientEvent:Connect(function(snapshot)
	ClientState:ApplySnapshot(snapshot)
end)
