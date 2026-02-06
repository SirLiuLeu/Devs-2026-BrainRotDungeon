local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Enemies = workspace:WaitForChild("Enemies")

local MonsterConfig = require(ServerScriptService.Data.MonsterConfig)

local ATTACK_COOLDOWN = 1

--------------------------------------------------

local function getNearestPlayer(monster, range)
	local nearest, minDist = nil, range
	for _, plr in Players:GetPlayers() do
		local char = plr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if hrp and hum and hum.Health > 0 then
			local dist = (hrp.Position - monster.PrimaryPart.Position).Magnitude
			if dist < minDist then
				nearest, minDist = char, dist
			end
		end
	end
	return nearest, minDist
end

local function getMonsterConfig(monster)
	return MonsterConfig[monster.Name] or MonsterConfig.Default
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

	local attackRangeValue = setConfigValue("AttackRange", configData.AttackRange or 5)
	local aggroRangeValue = setConfigValue("AggroRange", configData.AggroRange or 25)
	local damageValue = setConfigValue("Damage", configData.Damage or 10)

	local humanoid = monster:FindFirstChild("Humanoid")
	if humanoid and configData.MaxHP then
		humanoid.MaxHealth = configData.MaxHP
		humanoid.Health = humanoid.MaxHealth
	end

	return config, attackRangeValue, aggroRangeValue, damageValue
end

local function setupMonster(monster)
	if not monster:IsA("Model") then
		return
	end

	local humanoid = monster:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")
	local animations = game:GetService("ReplicatedStorage").Assets.Animations.Monster:FindFirstChild(monster.Name)
	if not humanoid or not animator or not animations then
		return
	end

	local primaryPart = monster.PrimaryPart or monster:FindFirstChild("HumanoidRootPart")
	if not primaryPart then
		return
	end
	monster.PrimaryPart = primaryPart

	local configData = getMonsterConfig(monster)
	local config, attackRangeValue, aggroRangeValue, damageValue = applyMonsterConfig(monster, configData)
	if not config or not attackRangeValue or not aggroRangeValue or not damageValue then
		return
	end

	local homeCFrame = monster.PrimaryPart.CFrame
	local returning = false
	local lastAttack = 0

	local runTrack = animator:LoadAnimation(animations.Run)
	runTrack.Priority = Enum.AnimationPriority.Movement

	local attackTrack = animator:LoadAnimation(animations.Attack)
	local rewardConfig = configData.Rewards or {}

	humanoid.Died:Connect(function()
		local lastHitId = monster:GetAttribute("LastHitPlayerId")
		if not lastHitId then
			return
		end
		local player = Players:GetPlayerByUserId(lastHitId)
		if not player then
			return
		end
		local data = player:FindFirstChild("Data")
		if not data then
			return
		end
		local expValue = data:FindFirstChild("Exp")
		local goldValue = data:FindFirstChild("Gold")
		if expValue then
			expValue.Value += rewardConfig.Exp or 0
		end
		if goldValue then
			goldValue.Value += rewardConfig.Gold or 0
		end
	end)

	local function stopRun()
		if runTrack.IsPlaying then
			runTrack:Stop()
		end
	end

	local function chase(target)
		local hrp = target:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		humanoid:MoveTo(hrp.Position)
		if not runTrack.IsPlaying then
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
		if os.clock() - lastAttack < ATTACK_COOLDOWN then
			return
		end
		lastAttack = os.clock()

		stopRun()

		if not attackTrack.IsPlaying then
			attackTrack:Play()
		end
		if not monster:IsDescendantOf(Enemies) or not monster.PrimaryPart then
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

		local damage = damageValue.Value
		hum:TakeDamage(damage)
	end

	task.spawn(function()
		while monster:IsDescendantOf(Enemies) do
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

for _, monster in Enemies:GetChildren() do
	setupMonster(monster)
end

Enemies.ChildAdded:Connect(setupMonster)
