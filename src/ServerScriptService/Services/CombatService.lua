local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)
local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)

local PlayerStateService = require(script.Parent.PlayerStateService)

local CombatService = {}

local function resolveCharacter(target)
    if typeof(target) ~= "Instance" then
        return nil
    end

    if target:IsA("Player") then
        return target.Character
    end

    if target:IsA("Model") then
        return target
    end

    if target:IsA("BasePart") then
        return target:FindFirstAncestorOfClass("Model")
    end

    return nil
end

local function getWeaponConfig(weaponId)
    if weaponId and Weapons[weaponId] then
        return Weapons[weaponId]
    end
    return Weapons.Basic
end

function CombatService:ValidateAttack(player, target)
    if not player or not player:IsA("Player") then
        return false
    end

    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local targetCharacter = resolveCharacter(target)
    if not targetCharacter then
        return false
    end

    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetHumanoid or not targetRoot or targetHumanoid.Health <= 0 then
        return false
    end

    local weaponId = player:GetAttribute("EquippedWeaponId")
    local weaponConfig = getWeaponConfig(weaponId)
    local range = weaponConfig.Range or 0
    if (targetRoot.Position - hrp.Position).Magnitude > range then
        return false
    end

    local state = PlayerStateService:GetState(player)
    if not state then
        return false
    end

    local lastAttack = state.Cooldowns.Attack or 0
    local cooldown = weaponConfig.Cooldown or 0
    if os.clock() - lastAttack < cooldown then
        return false
    end

    return true
end

function CombatService:ApplyDamage(attacker, target, weaponId)
    if not attacker or not target then
        return false
    end

    local targetCharacter = resolveCharacter(target)
    if not targetCharacter then
        return false
    end

    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        return false
    end

    if attacker:IsA("Player") then
        if not self:ValidateAttack(attacker, targetCharacter) then
            return false
        end

        local weaponConfig = getWeaponConfig(weaponId or attacker:GetAttribute("EquippedWeaponId"))
        local state = PlayerStateService:GetState(attacker)
        if not state then
            return false
        end

        local baseDamage = weaponConfig.Damage or 0
        local bonusDamage = state.Stats.Damage or 0
        local damage = math.max(0, baseDamage + bonusDamage)

        local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
        if targetPlayer then
            local targetState = PlayerStateService:GetState(targetPlayer)
            if targetState then
                damage = math.max(1, damage - (targetState.Stats.Defense or 0))
            end
        end

        targetHumanoid:TakeDamage(damage)
        state.Cooldowns.Attack = os.clock()

        local monsterConfig = Monsters[targetCharacter.Name]
        if monsterConfig then
            targetCharacter:SetAttribute("LastHitPlayerId", attacker.UserId)
        end

        return true
    end

    if attacker:IsA("Model") then
        local monsterConfig = Monsters[attacker.Name] or Monsters.Default
        local damage = monsterConfig.Damage or 0

        local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
        if targetPlayer then
            local targetState = PlayerStateService:GetState(targetPlayer)
            if targetState then
                damage = math.max(1, damage - (targetState.Stats.Defense or 0))
            end
        end

        targetHumanoid:TakeDamage(damage)
        return true
    end

    return false
end

return CombatService
