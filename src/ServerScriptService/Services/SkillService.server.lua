local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remote = ReplicatedStorage.Shared.Remotes.UseSkill

local CooldownService = require(ServerScriptService.Systems.CooldownService)
local StatService = require(ServerScriptService.Systems.StatService)
local SkillConfig = require(ReplicatedStorage.Shared.Config.Skills)

Remote.OnServerEvent:Connect(function(player, mode, skillName)
	if mode ~= "Hit" then return end
	local skillId = skillName or "Basic"
	local skill = SkillConfig[skillId] or SkillConfig.Basic
	if not CooldownService:IsReady(player, skillId) then return end
	CooldownService:StartCooldown(player, skillId, skill.Cooldown or 0)

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
    
	-- damage
	if workspace:FindFirstChild("Enemies") then
		local damagePercent = skill and skill.DamagePercent or 1
		local range = skill and skill.Range or 20
		local baseDamage = StatService:GetFinalDamage(player)
		local damage = baseDamage * damagePercent

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

end)
