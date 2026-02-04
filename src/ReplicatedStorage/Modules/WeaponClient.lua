local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage.Remotes.UseSkill


local WeaponClient = {}
WeaponClient.__index = WeaponClient
-- Tool

function WeaponClient.new(tool)
	local self = setmetatable({}, WeaponClient)

	self.Tool = tool
	self.Handle = tool:WaitForChild("Handle")
	self.Trail = self.Handle:WaitForChild("Trail")
	self.Trail.Enabled = false

	self.Character = nil
	self.Humanoid = nil
	self.Animator = nil
	self.canAttack = true

	return self
end

function WeaponClient:Cleanup()
	self.Trail.Enabled = false
	self.Character = nil
	self.Humanoid = nil
	self.Animator = nil
end

function WeaponClient:BindCharacter(character, humanoid)
	self.Character = character
	self.Humanoid = humanoid

	self.Animator = humanoid:FindFirstChildOfClass("Animator")
		or Instance.new("Animator", humanoid)
end


-- ========== CORE ==========
function WeaponClient:PlayAttack(attackName, animId, trail, Cooldown)
	if not self.canAttack or not self.Animator then return end
	self.canAttack = false
	
	local animId = animId
	if not animId then
		self.canAttack = true
		return
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId

	local track = self.Animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()

	local hitTime = track.Length * 0.35

	task.delay(hitTime, function()
		self.Trail.Enabled = true
		Remote:FireServer("Hit", attackName)
	end)

	task.delay(hitTime + trail, function()
		self.Trail.Enabled = false
	end)

	task.delay(Cooldown, function()
		self.canAttack = true
	end)
end

return WeaponClient