local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CombatService = require(script.Parent.CombatService)
local PlayerStateService = require(script.Parent.PlayerStateService)
local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local AutoFarmRemote = Remotes:FindFirstChild("AutoFarmToggle")
if not AutoFarmRemote then
	AutoFarmRemote = Instance.new("RemoteEvent")
	AutoFarmRemote.Name = "AutoFarmToggle"
	AutoFarmRemote.Parent = Remotes
end

local function getWeaponConfig(player)
	local weaponId = player:GetAttribute("EquippedWeaponId")
	return Weapons[weaponId] or Weapons.Basic
end

local function findTarget(player)
	local enemies = workspace:FindFirstChild("Enemies")
	if not enemies then
		return nil
	end
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return nil
	end

	local weaponConfig = getWeaponConfig(player)
	local searchRange = weaponConfig.Range or 6
	local closest
	local closestDist = searchRange

	for _, enemy in ipairs(enemies:GetChildren()) do
		local eh = enemy:FindFirstChildOfClass("Humanoid")
		local erp = enemy:FindFirstChild("HumanoidRootPart")
		if eh and erp and eh.Health > 0 then
			local dist = (erp.Position - hrp.Position).Magnitude
			if dist <= closestDist then
				closest = enemy
				closestDist = dist
			end
		end
	end

	return closest
end

AutoFarmRemote.OnServerEvent:Connect(function(player, enabled)
	local state = PlayerStateService:GetState(player)
	if not state then
		return
	end
	state.AutoFarm.Enabled = enabled and true or false
	if not state.AutoFarm.Enabled then
		state.AutoFarm.CurrentTarget = nil
	end
	PlayerStateService:Replicate(player)
end)

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local state = PlayerStateService:GetState(player)
			if state and state.AutoFarm.Enabled then
				local target = findTarget(player)
				state.AutoFarm.CurrentTarget = target
				if target then
					CombatService:ApplyDamage(player, target, nil)
				end
			end
		end
		task.wait(0.2)
	end
end)
