local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remote = ReplicatedStorage.Remotes.UseSkill

local SkillConfig = require(ServerScriptService.Data.SkillConfig)

local Cooldown = {}
local COOLDOWN_TIME = 1.5
Remote.OnServerEvent:Connect(function(player, mode, skillName)
	if mode ~= "Hit" then return end
	-- cooldown
	if Cooldown[player] then return end
	Cooldown[player] = true

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
    
	-- damage
	if workspace:FindFirstChild("Enemies") then
		local data = player:FindFirstChild("Data")
		local baseDamageValue = data and data:FindFirstChild("BaseDamage")
		local weaponDamageValue = data and data:FindFirstChild("WeaponDamage")
		local baseDamage = baseDamageValue and baseDamageValue.Value or 0
		local weaponDamage = weaponDamageValue and weaponDamageValue.Value or 0
		local skill = SkillConfig[skillName] or SkillConfig.Basic
		local damagePercent = skill and skill.DamagePercent or 1
		local range = skill and skill.Range or 20
		local damage = (baseDamage + weaponDamage) * damagePercent

		for _, enemy in pairs(workspace.Enemies:GetChildren()) do
			local eh = enemy:FindFirstChildOfClass("Humanoid")
			local erp = enemy:FindFirstChild("HumanoidRootPart")
			if eh and erp then
				local dist = (erp.Position - hrp.Position).Magnitude
				if dist <= range then
					enemy:SetAttribute("LastHitPlayerId", player.UserId)
					eh:TakeDamage(damage)
				end
			end
		end
	end

	task.delay(COOLDOWN_TIME, function()
		Cooldown[player] = nil
	end)
end)
