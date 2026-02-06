local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local CombatService = require(script.Parent.CombatService)

local MonsterService = {}

local function getMonsterConfig(monster)
    return Monsters[monster.Name] or Monsters.Default
end

local function resolveTargetCharacter(target)
    if typeof(target) ~= "Instance" then
        return nil
    end

    if target:IsA("Player") then
        return target.Character
    end

    if target:IsA("Model") then
        return target
    end

    return nil
end

function MonsterService:UpdateAggro(monster, dt)
    if not monster or not monster:IsA("Model") then
        return nil
    end

    local primary = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart")
    if not primary then
        return nil
    end

    local config = getMonsterConfig(monster)
    local aggroRange = config.AggroRange or 0
    local closest
    local minDist = aggroRange

    for _, player in Players:GetPlayers() do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        if hrp and humanoid and humanoid.Health > 0 then
            local dist = (hrp.Position - primary.Position).Magnitude
            if dist <= minDist then
                minDist = dist
                closest = player
            end
        end
    end

    if closest then
        monster:SetAttribute("AggroTargetId", closest.UserId)
        return closest
    end

    monster:SetAttribute("AggroTargetId", nil)
    return nil
end

function MonsterService:PerformAttack(monster, target)
    if not monster or not monster:IsA("Model") then
        return false
    end

    local primary = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart")
    if not primary then
        return false
    end

    local config = getMonsterConfig(monster)
    local attackRange = config.AttackRange or 0
    local cooldown = config.AttackCooldown or 1

    local targetCharacter = resolveTargetCharacter(target)
    if not targetCharacter then
        return false
    end

    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
    if not targetRoot or not targetHumanoid or targetHumanoid.Health <= 0 then
        return false
    end

    if (targetRoot.Position - primary.Position).Magnitude > attackRange then
        return false
    end

    local lastAttack = monster:GetAttribute("LastAttackTime") or 0
    if os.clock() - lastAttack < cooldown then
        return false
    end

    monster:SetAttribute("LastAttackTime", os.clock())

    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    CombatService:ApplyDamage(monster, targetPlayer or targetCharacter, nil)

    return true
end

return MonsterService
