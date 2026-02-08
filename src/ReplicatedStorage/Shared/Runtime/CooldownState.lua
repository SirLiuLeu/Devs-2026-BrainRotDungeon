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

function CooldownState:GetRemaining(skillSlot)
	local nextReady = nextReadyBySkill[skillSlot] or 0
	local remaining = nextReady - getServerTime()
	if remaining < 0 then
		return 0
	end
	return remaining
end

function CooldownState:IsReady(skillSlot)
	return self:GetRemaining(skillSlot) <= 0
end

function CooldownState:MarkPredicted(skillSlot, duration)
	if not duration then
		return
	end
	local predictedReady = getServerTime() + duration
	local existing = nextReadyBySkill[skillSlot] or 0
	if predictedReady > existing then
		nextReadyBySkill[skillSlot] = predictedReady
	end
end

local function applyServerReady(skillSlot, nextReady)
	if typeof(nextReady) ~= "number" then
		return
	end
	local existing = nextReadyBySkill[skillSlot] or 0
	if nextReady > existing then
		nextReadyBySkill[skillSlot] = nextReady
	end
end

Remote.OnClientEvent:Connect(function(mode, skillSlot, payload)
	if mode == "CooldownSync" then
		if typeof(skillSlot) == "number" then
			timeOffset = skillSlot - os.clock()
		end
		return
	end

	if mode == "CooldownStart" then
		applyServerReady(skillSlot, payload)
	end
end)

Remote:FireServer("CooldownSyncRequest")

return CooldownState
