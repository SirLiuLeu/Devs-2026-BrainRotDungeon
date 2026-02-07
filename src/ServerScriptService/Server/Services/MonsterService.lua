local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local Assets = ReplicatedStorage.Shared:FindFirstChild("Assets")

local CombatService = require(script.Parent.CombatService)
local MonsterLifecycleService = require(script.Parent.MonsterLifecycleService)
local RewardService = require(script.Parent.RewardService)
local RoomService = require(script.Parent.RoomService)

local MonsterService = {}
MonsterService.Monsters = {}

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

local function applyConfig(monster, config)
    local configFolder = monster:FindFirstChild("Config")
    if not configFolder then
        configFolder = Instance.new("Folder")
        configFolder.Name = "Config"
        configFolder.Parent = monster
    end

    local function setValue(name, value)
        local obj = configFolder:FindFirstChild(name)
        if not obj then
            obj = Instance.new("NumberValue")
            obj.Name = name
            obj.Parent = configFolder
        end
        obj.Value = value
        return obj
    end

    setValue("Damage", config.Damage or 5)
    setValue("HP", config.MaxHP or 100)
    setValue("AttackRange", config.AttackRange or 5)
    setValue("Cooldown", config.AttackCooldown or 1)

    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.MaxHealth = config.MaxHP or humanoid.MaxHealth
        humanoid.Health = humanoid.MaxHealth
    end
end

function MonsterService:UpdateAggro(monster)
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

    if not monster:GetAttribute("AIEnabled") then
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

function MonsterService:SetupMonster(monster)
    if not monster or not monster:IsA("Model") then
        return
    end

    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local primaryPart = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart")
    if primaryPart then
        monster.PrimaryPart = primaryPart
    end

    local config = getMonsterConfig(monster)
    applyConfig(monster, config)

    local animationFolder = Assets and Assets:FindFirstChild("Animations")
    local soundFolder = Assets and Assets:FindFirstChild("Sounds")
    local monsterAnimations = animationFolder and animationFolder:FindFirstChild("Monsters")
    local monsterSounds = soundFolder and soundFolder:FindFirstChild("Monsters")
    monster:SetAttribute("HasAnimationAssets", monsterAnimations and monsterAnimations:FindFirstChild(monster.Name) ~= nil)
    monster:SetAttribute("HasSoundAssets", monsterSounds and monsterSounds:FindFirstChild(monster.Name) ~= nil)

    local lifecycle = MonsterLifecycleService:Bind(monster)
    self.Monsters[monster] = lifecycle

    monster:SetAttribute("IsAlive", true)
    monster:SetAttribute("AIEnabled", true)
    RoomService:RegisterEnemy(monster)

    humanoid.Died:Connect(function()
        RewardService:GrantRewards(monster)
        lifecycle:Kill()
    end)

    task.spawn(function()
        while monster.Parent do
            if not lifecycle:IsAlive() then
                task.wait(0.2)
            else
                local target = self:UpdateAggro(monster)
                if target then
                    self:PerformAttack(monster, target)
                end
                task.wait(0.2)
            end
        end
    end)
end

function MonsterService:GetMonster(monster)
    return self.Monsters[monster]
end

function MonsterService:Start()
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then
        enemiesFolder = Instance.new("Folder")
        enemiesFolder.Name = "Enemies"
        enemiesFolder.Parent = workspace
    end

    for _, monster in ipairs(enemiesFolder:GetChildren()) do
        self:SetupMonster(monster)
    end

    enemiesFolder.ChildAdded:Connect(function(child)
        self:SetupMonster(child)
    end)
end

return MonsterService
