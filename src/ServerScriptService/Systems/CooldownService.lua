local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local Remote = Remotes:WaitForChild("UseSkill")

local CooldownService = {}
CooldownService.__index = CooldownService

CooldownService._nextReadyByPlayer = {}
CooldownService._syncedPlayers = {}

local function getPlayerCooldowns(player)
	local data = CooldownService._nextReadyByPlayer[player]
	if not data then
		data = {}
		CooldownService._nextReadyByPlayer[player] = data
	end
	return data
end

function CooldownService:GetNextReady(player, skillId)
	local cooldowns = getPlayerCooldowns(player)
	return cooldowns[skillId] or 0
end

function CooldownService:IsReady(player, skillId)
	local now = os.clock()
	local nextReady = self:GetNextReady(player, skillId)
	return now >= nextReady
end

function CooldownService:StartCooldown(player, skillId, duration)
	local now = os.clock()
	local nextReady = now + duration
	local cooldowns = getPlayerCooldowns(player)
	cooldowns[skillId] = nextReady
	Remote:FireClient(player, "CooldownStart", skillId, nextReady)
	return nextReady
end

function CooldownService:SyncPlayer(player)
	if self._syncedPlayers[player] then
		return
	end
	self._syncedPlayers[player] = true
	Remote:FireClient(player, "CooldownSync", os.clock())
end

Players.PlayerAdded:Connect(function(player)
	CooldownService:SyncPlayer(player)
end)

Remote.OnServerEvent:Connect(function(player, mode)
	if mode ~= "CooldownSyncRequest" then
		return
	end
	CooldownService:SyncPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	CooldownService._nextReadyByPlayer[player] = nil
	CooldownService._syncedPlayers[player] = nil
end)

return CooldownService
