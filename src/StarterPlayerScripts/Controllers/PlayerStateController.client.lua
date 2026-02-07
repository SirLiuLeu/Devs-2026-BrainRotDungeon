local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clientRoot = script.Parent.Parent:WaitForChild("Client")
local ClientState = require(clientRoot:WaitForChild("ClientState"))

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local StateUpdate = Remotes:WaitForChild("StateUpdate")

StateUpdate.OnClientEvent:Connect(function(snapshot)
	ClientState:ApplySnapshot(snapshot)
end)
