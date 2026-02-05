local Remote = game.ReplicatedStorage.Remotes.DamageMonster

Remote.OnServerEvent:Connect(function(player, monster)
	-- validate monster
	if not monster
		or not monster:IsDescendantOf(workspace.La_Vacca_Saturno_Saturnita)
		or not monster.PrimaryPart then
		return
	end

	local hum = monster:FindFirstChild("Humanoid")
	if not hum or hum.Health <= 0 then return end

	-- LẤY CONFIG TỪ SERVER
	local config = monster:FindFirstChild("Config")
	if not config then return end

	local damageValue = config:FindFirstChild("Damage")
	local rangeValue = config:FindFirstChild("AttackRange")

	if not damageValue or not rangeValue then return end

	local damage = damageValue.Value
	local range = rangeValue.Value

	-- validate player
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- anti-hack: check range từ CONFIG
	if (hrp.Position - monster.PrimaryPart.Position).Magnitude > range then
		return
	end

	-- SERVER quyết định damage
	print("Damaging monster ", monster.Name, " for ", damage)
	hum:TakeDamage(damage)
end)