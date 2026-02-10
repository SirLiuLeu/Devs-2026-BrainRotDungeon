local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Weapons = require(ReplicatedStorage.Shared.Config.Weapons)
local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)

local PlayerStateService = require(script.Parent.PlayerStateService)
local RewardService = require(script.Parent.RewardService)
local StatService = require(script.Parent.Parent.Systems.StatService)
local RoomService = require(script.Parent.RoomService)

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

local function getMonsterConfig(monsterName)
    if Monsters[monsterName] then
        return Monsters[monsterName]
    end
    if Monsters.DesignCatalog and Monsters.DesignCatalog[monsterName] then
        return Monsters.DesignCatalog[monsterName]
    end
    return nil
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

    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if targetPlayer then
        if not RoomService:CanInteract(player, targetPlayer) then
            return false
        end
    elseif not RoomService:CanInteract(player, targetCharacter) then
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

        local damage = StatService:GetFinalDamage(attacker, weaponId)

        local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
        if targetPlayer then
            local targetState = PlayerStateService:GetState(targetPlayer)
            if targetState then
                damage = math.max(1, damage - (targetState.FinalStats.Defense or 0))
            end
        end

        targetHumanoid:TakeDamage(damage)
        state.Cooldowns.Attack = os.clock()

        local monsterConfig = getMonsterConfig(targetCharacter.Name)
        if monsterConfig then
            targetCharacter:SetAttribute("LastHitPlayerId", attacker.UserId)
            RewardService:TrackDamage(targetCharacter, attacker, damage)
        end

        return true
    end

    if attacker:IsA("Model") then
        local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
        if targetPlayer then
            if not RoomService:CanInteract(attacker, targetPlayer) then
                return false
            end
        elseif not RoomService:CanInteract(attacker, targetCharacter) then
            return false
        end
        local monsterConfig = Monsters[attacker.Name] or Monsters.Default
        local damage = monsterConfig.Damage or 0

        local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
        if targetPlayer then
            local targetStats = StatService:GetFinalStats(targetPlayer)
            damage = math.max(1, damage - (targetStats.Defense or 0))
        end

        targetHumanoid:TakeDamage(damage)
        return true
    end

    return false
end

function CombatService:ApplySkillDamage(player, target, skillConfig, weaponId)
    if not player or not player:IsA("Player") or not skillConfig then
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
    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if targetPlayer then
        if not RoomService:CanInteract(player, targetPlayer) then
            return false
        end
    elseif not RoomService:CanInteract(player, targetCharacter) then
        return false
    end
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetHumanoid or not targetRoot or targetHumanoid.Health <= 0 then
        return false
    end

    local range = skillConfig.Range or 0
    if (targetRoot.Position - hrp.Position).Magnitude > range then
        return false
    end

    local damagePercent = skillConfig.DamagePercent or 1
    local damageFlat = skillConfig.DamageFlat or 0
    local baseDamage = StatService:GetFinalDamage(player, weaponId)
    local damage = math.max(0, baseDamage * damagePercent + damageFlat)

    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if targetPlayer then
        local targetStats = StatService:GetFinalStats(targetPlayer)
        damage = math.max(1, damage - (targetStats.Defense or 0))
    end

    targetHumanoid:TakeDamage(damage)

    local monsterConfig = getMonsterConfig(targetCharacter.Name)
    if monsterConfig then
        targetCharacter:SetAttribute("LastHitPlayerId", player.UserId)
        RewardService:TrackDamage(targetCharacter, player, damage)
    end

    return true
end

return CombatService
