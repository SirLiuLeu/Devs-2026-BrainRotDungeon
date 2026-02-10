local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Remote = ReplicatedStorage.Shared.Remotes.UseSkill

local CooldownService = require(ServerScriptService.Systems.CooldownService)
local CombatService = require(ServerScriptService.Services.CombatService)
local PlayerStateService = require(ServerScriptService.Services.PlayerStateService)
local StatService = require(ServerScriptService.Systems.StatService)
local SkillConfig = require(ReplicatedStorage.Shared.Config.Skills)
local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)
local RoomService = require(ServerScriptService.Services.RoomService)

local function getWeaponConfig(weaponId)
	return Weapons[weaponId] or Weapons.Basic
end

local function getSkillIdForSlot(weaponConfig, skillSlot)
	if not weaponConfig or not skillSlot then
		return nil
	end
	local slots = weaponConfig.SkillSlots or {}
	return slots[skillSlot]
end

local function getTargetsInRange(player, range, targeting)
	local targets = {}
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not workspace:FindFirstChild("Enemies") then
		return targets
	end

	local closestTarget
	local closestDist = range or 0

	for _, enemy in ipairs(workspace.Enemies:GetChildren()) do
		local eh = enemy:FindFirstChildOfClass("Humanoid")
		local erp = enemy:FindFirstChild("HumanoidRootPart")
		if eh and erp and eh.Health > 0 and RoomService:CanInteract(player, enemy) then
			local dist = (erp.Position - hrp.Position).Magnitude
			if dist <= (range or 0) then
				if targeting == "Single" then
					if dist < closestDist then
						closestDist = dist
						closestTarget = enemy
					end
				else
					table.insert(targets, enemy)
				end
			end
		end
	end

	if targeting == "Single" and closestTarget then
		return { closestTarget }
	end

	return targets
end

local function applyHeal(player, skill)
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	local stats = StatService:GetFinalStats(player)
	local healAmount = (skill.HealFlat or 0) + (stats.MaxHP * (skill.HealPercent or 0))
	if healAmount <= 0 then
		return
	end
	humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + healAmount)
end

local function applyDash(player, skill)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end
	local distance = skill.DashDistance or 0
	if distance <= 0 then
		return
	end
	hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -distance)
end

local function applyDebuff(target, skill)
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local duration = skill.Duration or 0
	local moveMultiplier = skill.DebuffMoveSpeedMultiplier or 1
	if moveMultiplier <= 0 then
		moveMultiplier = 0.1
	end
	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * moveMultiplier
	if duration > 0 then
		task.delay(duration, function()
			if humanoid then
				humanoid.WalkSpeed = originalSpeed
			end
		end)
	end
end

local function applyStun(target, skill)
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	local duration = skill.Duration or 0
	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	if duration > 0 then
		task.delay(duration, function()
			if humanoid then
				humanoid.WalkSpeed = originalSpeed
				humanoid.JumpPower = originalJump
			end
		end)
	end
end

Remote.OnServerEvent:Connect(function(player, mode, skillSlot)
	if mode ~= "Hit" then return end
	local weaponId = player:GetAttribute("EquippedWeaponId")
	local weaponConfig = getWeaponConfig(weaponId)
	local skillId = getSkillIdForSlot(weaponConfig, skillSlot)
	if not skillId then
		return
	end
	local skill = SkillConfig[skillId]
	if not skill then
		return
	end
	if not CooldownService:IsReady(player, skillSlot) then return end
	CooldownService:StartCooldown(player, skillSlot, skill.Cooldown or 0)

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
    
	local effectType = skill.EffectType or "Damage"
	local targeting = skill.Targeting or "AOE"
	local range = skill.Range or 20
	if effectType == "Damage" then
		local targets = getTargetsInRange(player, range, targeting)
		for _, target in ipairs(targets) do
			CombatService:ApplySkillDamage(player, target, skill, weaponId)
		end
	elseif effectType == "Heal" then
		applyHeal(player, skill)
	elseif effectType == "Buff" then
		PlayerStateService:ApplyBuff(player, skill.BuffStats or {}, skill.Duration)
	elseif effectType == "Debuff" then
		local targets = getTargetsInRange(player, range, targeting)
		for _, target in ipairs(targets) do
			applyDebuff(target, skill)
		end
	elseif effectType == "Stun" then
		local targets = getTargetsInRange(player, range, targeting)
		for _, target in ipairs(targets) do
			applyStun(target, skill)
		end
	elseif effectType == "Dash" then
		applyDash(player, skill)
	elseif effectType == "Passive" then
		PlayerStateService:ApplyBuff(player, skill.BuffStats or {}, skill.Duration)
	end

end)
