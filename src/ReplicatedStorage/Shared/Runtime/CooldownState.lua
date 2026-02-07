local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local Remote = Remotes:WaitForChild("UseSkill")

local CooldownState = {}
CooldownState.__index = CooldownState

local nextReadyBySkill = {}
local timeOffset = 0

local function getServerTime()
	return os.clock() + timeOffset
end

function CooldownState:GetRemaining(skillId)
	local nextReady = nextReadyBySkill[skillId] or 0
	local remaining = nextReady - getServerTime()
	if remaining < 0 then
		return 0
	end
	return remaining
end

function CooldownState:IsReady(skillId)
	return self:GetRemaining(skillId) <= 0
end

function CooldownState:MarkPredicted(skillId, duration)
	if not duration then
		return
	end
	local predictedReady = getServerTime() + duration
	local existing = nextReadyBySkill[skillId] or 0
	if predictedReady > existing then
		nextReadyBySkill[skillId] = predictedReady
	end
end

local function applyServerReady(skillId, nextReady)
	if typeof(nextReady) ~= "number" then
		return
	end
	local existing = nextReadyBySkill[skillId] or 0
	if nextReady > existing then
		nextReadyBySkill[skillId] = nextReady
	end
end

Remote.OnClientEvent:Connect(function(mode, skillId, payload)
	if mode == "CooldownSync" then
		if typeof(skillId) == "number" then
			timeOffset = skillId - os.clock()
		end
		return
	end

	if mode == "CooldownStart" then
		applyServerReady(skillId, payload)
	end
end)

Remote:FireServer("CooldownSyncRequest")

return CooldownState
