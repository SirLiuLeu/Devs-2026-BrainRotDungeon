local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monsters = require(ReplicatedStorage.Shared.Config.Monsters)
local CombatService = require(script.Parent.CombatService)
local RewardService = require(script.Parent.RewardService)
local RoomService = require(script.Parent.RoomService)

local MonsterService = {}

local function getMonsterConfig(monster)
	return Monsters[monster.Name]
		or (Monsters.DesignCatalog and Monsters.DesignCatalog[monster.Name])
		or Monsters.Default
end

local function applyMonsterConfig(monster, configData)
	local config = monster:FindFirstChild("Config")
	if not config then
		config = Instance.new("Folder")
		config.Name = "Config"
		config.Parent = monster
	end

	local function setConfigValue(name, value)
		local valueObject = config:FindFirstChild(name)
		if not valueObject then
			valueObject = Instance.new("NumberValue")
			valueObject.Name = name
			valueObject.Parent = config
		end
		valueObject.Value = value
		return valueObject
	end

	local stats = configData.Stats or configData
	local attackRangeValue = setConfigValue("AttackRange", stats.AttackRange or stats.Range or 5)
	local aggroRangeValue = setConfigValue("AggroRange", stats.AggroRange or 25)
	local damageValue = setConfigValue("Damage", stats.Damage or 10)
	local cooldownValue = setConfigValue("AttackCooldown", stats.Cooldown or stats.AttackCooldown or 1)

	local humanoid = monster:FindFirstChild("Humanoid")
	if humanoid and stats.HP then
		humanoid.MaxHealth = stats.HP
		humanoid.Health = humanoid.MaxHealth
	elseif humanoid and configData.MaxHP then
		humanoid.MaxHealth = configData.MaxHP
		humanoid.Health = humanoid.MaxHealth
	end

	return config, attackRangeValue, aggroRangeValue, damageValue, cooldownValue
end

local function getNearestPlayer(monster, range)
	local nearest, minDist = nil, range
	for _, plr in Players:GetPlayers() do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if hrp and hum and hum.Health > 0 and RoomService:CanInteract(plr, monster) then
			local dist = (hrp.Position - monster.PrimaryPart.Position).Magnitude
			if dist < minDist then
				nearest, minDist = char, dist
			end
		end
	end
	return nearest, minDist
end

local function setupMonster(monster, enemies)
	if not monster:IsA("Model") then
		return
	end

	local humanoid = monster:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local animations = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Animations")
		and ReplicatedStorage.Assets.Animations:FindFirstChild("Monster")
		and ReplicatedStorage.Assets.Animations.Monster:FindFirstChild(monster.Name)
	if not humanoid or not animator then
		return
	end

	local primaryPart = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart")
	if not primaryPart then
		return
	end
	monster.PrimaryPart = primaryPart

	local configData = getMonsterConfig(monster)
	RoomService:AssignEnemy(monster, monster:GetAttribute("RoomId") or 0)
	local _, attackRangeValue, aggroRangeValue, damageValue, cooldownValue = applyMonsterConfig(monster, configData)
	if not attackRangeValue or not aggroRangeValue or not damageValue or not cooldownValue then
		return
	end

	local homeCFrame = monster.PrimaryPart.CFrame
	local returning = false
	local lastAttack = 0

	local runTrack
	local attackTrack
	if animations then
		if animations:FindFirstChild("Run") then
			runTrack = animator:LoadAnimation(animations.Run)
			runTrack.Priority = Enum.AnimationPriority.Movement
		end
		if animations:FindFirstChild("Attack") then
			attackTrack = animator:LoadAnimation(animations.Attack)
		end
	end

	humanoid.Died:Connect(function()
		RewardService:HandleMonsterDeath(monster)
	end)

	monster.AncestryChanged:Connect(function(_, parent)
		if not parent then
			RewardService:ClearMonster(monster)
			RoomService:ClearEntity(monster)
		end
	end)

	local function stopRun()
		if runTrack and runTrack.IsPlaying then
			runTrack:Stop()
		end
	end

	local function chase(target)
		local hrp = target:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		humanoid:MoveTo(hrp.Position)
		if runTrack and not runTrack.IsPlaying then
			runTrack:Play()
		end
	end

	local function returnHome()
		if returning then
			return
		end
		returning = true
		stopRun()
		humanoid:MoveTo(homeCFrame.Position)

		task.spawn(function()
			humanoid.MoveToFinished:Wait()
			returning = false
		end)
	end

	local function attack(target)
		if os.clock() - lastAttack < cooldownValue.Value then
			return
		end
		lastAttack = os.clock()

		stopRun()

		if attackTrack and not attackTrack.IsPlaying then
			attackTrack:Play()
		end
		if not monster:IsDescendantOf(enemies) or not monster.PrimaryPart then
			return
		end

		local hum = target:FindFirstChild("Humanoid")
		if not hum or hum.Health <= 0 then
			return
		end

		local range = attackRangeValue.Value

		local hrp = target:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		if (hrp.Position - monster.PrimaryPart.Position).Magnitude > range then
			return
		end

		local targetPlayer = Players:GetPlayerFromCharacter(target)
		CombatService:ApplyDamage(monster, targetPlayer or target, nil)
	end

	task.spawn(function()
		while monster:IsDescendantOf(enemies) do
			if humanoid.Health <= 0 then
				stopRun()
				task.wait(0.2)
			else
				local target, dist = getNearestPlayer(monster, aggroRangeValue.Value)

				if not target then
					returnHome()
				elseif dist > attackRangeValue.Value then
					chase(target)
				else
					attack(target)
				end
				task.wait(0.2)
			end
		end
	end)
end

function MonsterService:Start(enemiesFolder)
	local enemies = enemiesFolder or workspace:WaitForChild("Enemies")
	for _, monster in ipairs(enemies:GetChildren()) do
		setupMonster(monster, enemies)
	end
	enemies.ChildAdded:Connect(function(monster)
		setupMonster(monster, enemies)
	end)
end

return MonsterService
