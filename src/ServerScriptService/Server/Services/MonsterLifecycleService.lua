local RoomService = require(script.Parent.RoomService)

local MonsterLifecycleService = {}
MonsterLifecycleService.RespawnDelay = 5
MonsterLifecycleService.Registry = {}

local function setCollision(model, canCollide)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = canCollide
        end
    end
end

local function disableAI(monster)
    monster:SetAttribute("AIEnabled", false)
    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.AutoRotate = false
    end
end

local function enableAI(monster)
    monster:SetAttribute("AIEnabled", true)
    local humanoid = monster:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.AutoRotate = true
    end
end

function MonsterLifecycleService:Bind(monster)
    if self.Registry[monster] then
        return self.Registry[monster]
    end

    local spawnCFrame = monster.PrimaryPart and monster.PrimaryPart.CFrame
        or monster:FindFirstChild("HumanoidRootPart") and monster.HumanoidRootPart.CFrame

    local wrapper = {
        Model = monster,
        Alive = true,
        SpawnCFrame = spawnCFrame,
    }

    function wrapper:Kill()
        if not self.Alive then
            return
        end

        self.Alive = false
        local model = self.Model
        model:SetAttribute("IsAlive", false)
        setCollision(model, false)
        disableAI(model)
        RoomService:UnregisterEnemy(model)

        task.delay(MonsterLifecycleService.RespawnDelay, function()
            if MonsterLifecycleService.Registry[model] == self then
                self:Respawn()
            end
        end)
    end

    function wrapper:Respawn()
        local model = self.Model
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end

        if self.SpawnCFrame and model.PrimaryPart then
            model:SetPrimaryPartCFrame(self.SpawnCFrame)
        elseif self.SpawnCFrame and model:FindFirstChild("HumanoidRootPart") then
            model.HumanoidRootPart.CFrame = self.SpawnCFrame
        end

        setCollision(model, true)
        enableAI(model)
        model:SetAttribute("IsAlive", true)
        model:SetAttribute("LastHitPlayerId", nil)
        model:SetAttribute("AggroTargetId", nil)
        model:SetAttribute("LastAttackTime", nil)
        self.Alive = true
        RoomService:RegisterEnemy(model)
    end

    function wrapper:IsAlive()
        return self.Alive
    end

    self.Registry[monster] = wrapper
    return wrapper
end

function MonsterLifecycleService:Get(monster)
    return self.Registry[monster]
end

return MonsterLifecycleService
