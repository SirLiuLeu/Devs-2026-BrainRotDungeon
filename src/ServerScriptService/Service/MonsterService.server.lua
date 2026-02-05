local Players = game:GetService("Players")

local monster = workspace.Enemies.La_Vacca_Saturno_Saturnita
local humanoid = monster:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

-- CONFIG
local ATTACK_RANGE = monster.Config.AttackRange.Value
local AGGRO_RANGE = monster.Config.AggroRange.Value

local homeCFrame = monster.PrimaryPart.CFrame
local returning = false

local runTrack = animator:LoadAnimation(monster.Animations.Run)
runTrack.Priority = Enum.AnimationPriority.Movement

--------------------------------------------------

local function getNearestPlayer(range)
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

local function stopRun()
	if runTrack.IsPlaying then
		runTrack:Stop()
	end
end

local function chase(target)
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	humanoid:MoveTo(hrp.Position)
	if not runTrack.IsPlaying then
		runTrack:Play()
	end
end

local function returnHome()
	if returning then return end
	returning = true
	stopRun()
	humanoid:MoveTo(homeCFrame.Position)

	task.spawn(function()
		humanoid.MoveToFinished:Wait()
		returning = false
	end)
end

local ATTACK_COOLDOWN = 1
local lastAttack = 0
local DAMAGE = 2
local attackTrack = animator:LoadAnimation(monster.Animations.Attack)
runTrack.Priority = Enum.AnimationPriority.Movement

local function attack(target)
	if os.clock() - lastAttack < ATTACK_COOLDOWN then
		return
	end
	lastAttack = os.clock()

	stopRun()

	if not attackTrack.IsPlaying then
		attackTrack:Play()
	end

	local hum = target:FindFirstChild("Humanoid")
	if hum then
		hum:TakeDamage(DAMAGE)
	end
end

--------------------------------------------------
-- AI LOOP
--------------------------------------------------
while task.wait(0.2) do
	local target, dist = getNearestPlayer(AGGRO_RANGE)

	if not target then
		returnHome()

	elseif dist > ATTACK_RANGE then
		chase(target)

	else
		attack(target) -- 🔥 ATTACK Ở ĐÂY
	end
end

